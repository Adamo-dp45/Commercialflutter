# commercialflutter — App mobile du commercial à bord

Application Flutter destinée au **commercial à bord** (vendeur mobile) d'iTransport : il suit ses
voyages en cours, fait avancer la position du car le long du trajet, et (à venir) vend des billets
depuis la position réelle du véhicule.

Contrairement à l'app client `resaflutter` (API publique anonyme), le commercial est un **utilisateur
authentifié** : l'app consomme l'API interne via **JWT** (LexikJWT + refresh gesdinet).

## Lancer

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère *.freezed.dart / *.g.dart
flutter run --dart-define=API_BASE_URL=https://proud-gauntlet-elongated.ngrok-free.dev # https://apitransport.socafpesage.com
```

- `API_BASE_URL` : racine du backend Symfony/API Platform (sans `/api`). `10.0.2.2` = l'hôte local vu depuis l'émulateur Android ; sur un appareil physique, mettez l'IP LAN de la machine (ex. `http://192.168.1.20:8000`). Pas de slug : le périmètre entreprise vient du compte.

> Windows : la compilation d'une app à plugins natifs exige le **mode développeur**
> (`start ms-settings:developers`) pour la prise en charge des liens symboliques.

## Architecture

Découpage **feature-first en couches** (Clean Architecture allégée), calqué sur `resaflutter` :

```
lib/
├── app.dart · main.dart
├── core/
│   ├── config/            # AppConfig (dart-define)
│   ├── network/           # Dio + ApiException + AuthInterceptor (Bearer + refresh 401)
│   ├── auth/              # TokenStore (flutter_secure_storage)
│   ├── router/            # go_router + redirection selon l'état d'auth
│   ├── theme/ · formatting/ · widgets/
└── features/
    ├── auth/              # login, profil (/api/me), AuthController
    └── voyages/           # « mes voyages » + progression (avancer / le car repart)
```

**Stack** : Riverpod 3 (état/DI) · dio (réseau) · freezed + json_serializable (modèles) · go_router
(navigation) · flutter_secure_storage (jetons) · intl (fr).

Règle de dépendance : `presentation → domain → data`. L'UI dépend d'interfaces de repository, jamais
de Dio directement (erreurs normalisées via `ApiException`, testable).

## Authentification

`POST /api/login_check` → `{token, refresh_token}` (stockés chiffrés). Chaque requête porte le Bearer ;
sur `401`, l'app tente **un** refresh (`/api/token/refresh`) et rejoue la requête, sinon déconnecte.
Au lancement, un refresh silencieux tente l'**auto-login**. Déconnexion : `/api/token/invalidate`.

## Périmètre

- **Socle** : connexion, « mes voyages » (recette propre, position du car), progression.
- **Vente à bord** : depuis la position du car → destination → plan de sièges → client → **remise
  facultative** (pourcentage ou montant, comme sur le web — le serveur applique le plafond de la
  compagnie) → billet (`POST /api/tickets`).
  - **Siège déjà vendu par une gare en aval** : signalé en **ambre**, flèche descendante, détail à
    l'appui long — et **parfaitement vendable**. La priorité amont reste la règle : le repère existe
    pour que le vendeur qui a le choix prenne un autre siège, parce que la plupart des évictions ne
    viennent pas d'un car plein mais d'un siège pris au hasard alors qu'un autre était libre. Un
    rappel s'affiche aussi à la sélection : le vendeur passe à l'étape suivante dès qu'il touche un
    siège, il ne relira pas la légende.
- **Bagage** : lié au billet si la permission `Bagage/CREER` est accordée, avec **montant forçable**
  (vide = calcul serveur d'après la grille de poids ; renseigné = `BagageInput.montant`). Le **reçu est
  proposé dès l'enregistrement** (à la vente comme dans « Mes ventes »).
- **Reçus PDF** au **même format que l'impression du front web** — billet
  (`mails/ticket/thermalpdf.html.twig` : en-tête sigle/gare via `/api/me/entreprise`, trajet, grille
  voyage/siège, tarif, véhicule, **QR** code billet, souche) et bagage (`mails/bagage/ticket.html.twig`).
  Code partagé et autonome : [`core/pdf/recu_pdf.dart`](lib/core/pdf/recu_pdf.dart),
  [`core/pdf/bagage_recu_pdf.dart`](lib/core/pdf/bagage_recu_pdf.dart).
- **Mes ventes** (`/voyage/:id/ventes`) : mes billets et bagages du voyage —
  - **réimprimer** billet et bagage (non imprimés après la vente) ;
  - **corriger** selon mes droits : identité client (`Ticket/MODIFIER`), bagage nature/poids/montant ou
    annulation (`Bagage/MODIFIER`) ; suppression réservée à l'admin (non exposée) ;
  - **descendre un passager en route** (`Ticket/MODIFIER`) : le passager quitte le car à la position
    actuelle → `PATCH /tickets/{id}/descendre`, le siège est libéré pour une revente en aval ;
  - **ajouter un bagage** à un billet déjà vendu (`Bagage/CREER`), pas seulement au moment de la vente.
  - Lecture via l'endpoint **dédié** `GET /api/voyages/{id}/me/ventes` (`CommercialVentesController`),
    scopé au commercial connecté **côté serveur** et **hors périmètre gare** : les collections
    `/api/tickets` et `/api/bagages` sont filtrées par la gare d'attache de l'agent
    (`GareScopeExtension`) et masqueraient les ventes faites en route, hors de cette gare.
  - **Les actions suivent les gardes serveur** : un bagage n'est modifiable/annulable que tant qu'il est
    `ENREGISTRE` (une fois `EMBARQUE`, plus d'action) ; « modifier le client » n'apparaît que si le car
    est encore à la gare de montée du billet, « descendre » que si la position est entre la montée et la
    descente vendue. Toute correction rafraîchit aussi la recette (`mesVoyagesProvider`).
- **Manifeste** (`/voyage/:id/manifeste`) : liste nominative des passagers à bord (siège, client,
  trajet, canal à-bord/guichet), pour le contrôle. `GET /api/voyages/{id}/me/manifeste`, réservé au
  commercial du voyage. Distinct de la feuille de route agrégée `/api/voyages/{id}/manifeste`
  (`VoyageManifesteController`, par gare/tronçon).
- **Ma recette** : synthèse cumulée (recette totale, billets, bagages, panier moyen) sur mes voyages
  **actifs**, dérivée de `/api/voyages/me/commercial` — aucun appel réseau dédié. Périmètre assumé :
  un voyage clôturé sort du cumul (rappelé dans l'écran).
- **Hors ligne** (`lib/core/offline/`) : le vendeur à bord travaille **sans réseau** — il vend,
  imprime, enregistre un bagage, fait avancer la position du car, déclare son départ de gare,
  consulte son manifeste et relit ses ventes pour réimprimer.
  - **Armement** : à l'ouverture d'un voyage, `GET /api/voyages/{id}/me/instantane` télécharge tout ce
    qu'il faut pour calculer seul — arrêts ordonnés, sièges **avec leur disposition** (rangée, côté),
    billets en cours, bagages, grille tarifaire, grille de poids, plafond de remise, en-tête de la
    compagnie. Sans instantané, l'application **refuse** de vendre plutôt que d'improviser un prix.
  - **Bascule** : jamais sur l'état déclaré du réseau (un téléphone accroché à une antenne sans débit
    se dit connecté), toujours sur l'échec RÉEL de l'appel (`ApiException.estHorsLigne`).
  - **Codes définitifs** : billet `…-TCK-2026-B3`, étiquette `…-BAG-2026-B2`. Une série « B » propre au
    bord, sûre parce qu'un voyage n'a qu'un seul commercial. Le reçu imprimé ne changera jamais de
    sens. Le compteur prend le **plus haut** de deux sources — la file locale ET les codes « B » déjà
    présents dans l'instantané : une réinstallation ne le ramène donc pas à zéro.
  - **Remontée AUTOMATIQUE** (`vidange_automatique.dart`) : la file repart seule, sur **quatre**
    déclencheurs, parce qu'aucun ne suffit — ouverture de la base locale, changement de connectivité,
    retour au premier plan, et une retentative toutes les 2 min **tant que la file n'est pas vide**.
    Ce dernier couvre le cas le plus fréquent en brousse : l'antenne reste « connectée » sans débit,
    puis le débit revient — aucun changement d'interface, donc aucun événement de connectivité. Le
    bouton de synchronisation reste offert, il n'est plus nécessaire.
  - **Idempotence** : `POST /api/voyages/{id}/me/sync` rejoue la file dans l'ordre d'émission. Chaque
    opération porte une référence — un lot se renvoie sans crainte. Un refus ne fait pas tomber le
    reste du lot, et une opération fautive ne bloque jamais celles qui la suivent.
  - **Ce que le téléphone corrige localement**, faute de quoi l'écran mentirait au vendeur :
    - la **position du car** — tout ce qu'il peut vendre ensuite s'en déduit ; le départ n'est plus
      proposé au terminus, comme côté serveur ;
    - **Ma performance** — recette, billets, bagages, places libres. La recette suit le **net**
      encaissé. Les mêmes chiffres alimentent l'accueil et « Ma recette ».
    Ces corrections sont écrasées dès le premier chargement réussi : le serveur reste la référence.
  - **Ce qu'il rejoue à l'identique** (`regles_rejouees_test.dart` les fixe) : le prix, l'occupation
    d'un siège (priorité amont, bornes illisibles → siège **bloqué** et non libéré), l'alerte
    « vendu en aval », la grille de poids, la remise **et son plafond**. Une règle rejouée doit
    refuser là où l'originale refuse — sinon le refus tombe à la synchronisation, après
    l'encaissement.
  - **L'alerte « vendu en aval » est rejouée, pas seulement affichée** : l'instantané porte déjà les
    bornes de chaque billet, son `nomclient` et son `evince`, donc le téléphone la recalcule seul.
    Elle décide de ce que le vendeur voit au moment de **choisir** — l'apprendre à la
    synchronisation ne servirait plus à rien, le passager serait déjà évincé. !! **les deux bornes
    comptent** (`debut > ordreMontee && debut < ordreDescente`). Sans la première, un passager qui
    **descend** à la gare du vendeur déclenchait l'alerte alors que son siège s'y libère — le faux
    positif livré côté serveur, et la revente la plus banale du réseau.
  - **Mes ventes en file suivent la même règle de tronçon** que les billets du serveur. Elles étaient
    bloquées en bloc, descente ignorée : un siège vendu Bouaké → Ferké restait occupé pour toujours
    aux yeux du vendeur, alors que son passager y descend et que le serveur le rend libre. Aucune
    mauvaise vente n'en découlait — seulement une place revendable perdue, hors réseau, là où l'on ne
    peut appeler personne pour comprendre pourquoi le plan refuse.
  - **La session survit** à un redémarrage sans réseau : profil et jetons gardés dans le coffre
    chiffré, liste des départs en cache. Sans cela, un téléphone qui redémarre en route renvoyait le
    vendeur à l'écran de connexion — avec ses ventes prisonnières d'une file inatteignable.
  - **Sort visible** : bandeau permanent (ce qui reste à remonter) + écran `/voyage/:id/operations`,
    qui montre chaque opération et son sort, motif de refus compris. C'est la contrepartie assumée du
    choix optimiste côté serveur : un billet dont le siège a été évincé doit se **voir**.
  - **Mes ventes hors ligne** : la liste et la **réimpression** fonctionnent (un passager perd son
    reçu en route, exactement là où il n'y a pas de couverture) ; les **corrections** restent en
    ligne, désactivées avec le motif affiché.
  - **Interdit hors ligne** : désistement (remboursement — caisse de gare), modification d'un billet
    ou d'un bagage, réservation, récompense de fidélité (deux appareils brûleraient la même).
- **À venir** : bilan de recette **par période** (aujourd'hui / 7j / 30j) incluant les voyages
  clôturés — nécessite un endpoint perso côté backend (`/api/stats/commercial` étant réservé à
  l'admin) ; fidélité à la vente.

## Développement

```bash
dart run build_runner watch --delete-conflicting-outputs   # régénération continue
flutter analyze
flutter test
```

Après toute modification d'un modèle `@freezed`, relancer `build_runner`.

### Deux pièges à connaître

**La permission `INTERNET` est déclarée dans `android/app/src/main/AndroidManifest.xml`, et doit y
rester.** Le gabarit Flutter ne la pose que dans les manifestes `debug` et `profile`, pour son propre
outillage — le variant `release` ne les inclut pas. Un APK publié sans elle ne peut ouvrir **aucune**
connexion : tous les appels échouent en `connectionError`, c'est-à-dire « Impossible de joindre le
serveur » quelle que soit l'adresse visée. Le trafic en clair (`usesCleartextTraffic`), lui, reste
**debug uniquement** : la production parle en HTTPS.

**Le `can()` de `AuthUser` est un MIROIR du `PermissionVoter` du backend.** Un `ROLE_ADMIN_GARE` y
agit sans permission explicite sur les entités bornées par sa gare — la liste `_gareScopedEntities`
reproduit `GareScopedEntities::ENTITIES` (`Voyage, Ticket, Reservation, Courrier, Bagage, User,
Role`). Cette duplication est assumée et commentée : si la liste change côté backend, celle-ci doit
suivre, sinon l'application masque des boutons que le serveur autorise.
