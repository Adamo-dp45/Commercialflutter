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
- **Hors ligne** (`lib/core/offline/`) : le vendeur à bord vend, imprime, enregistre un bagage, fait
  avancer la position du car et consulte son manifeste **sans réseau**.
  - **Armement** : à l'ouverture d'un voyage, `GET /api/voyages/{id}/me/instantane` télécharge tout ce
    qu'il faut pour calculer seul — arrêts ordonnés, sièges, billets en cours, grille tarifaire, grille
    de poids des bagages, plafond de remise, en-tête de la compagnie. Sans instantané, l'application
    **refuse** de vendre plutôt que d'improviser un prix.
  - **Bascule** : jamais sur l'état déclaré du réseau (un téléphone accroché à une antenne sans débit
    se dit connecté), toujours sur l'échec RÉEL de l'appel (`ApiException.estHorsLigne`).
  - **Codes définitifs** : billet `…-TCK-2026-B3`, étiquette `…-BAG-2026-B2`. Une série « B » propre au
    bord, sûre parce qu'un voyage n'a qu'un seul commercial. Le reçu imprimé ne changera jamais de sens.
  - **Remontée** : `POST /api/voyages/{id}/me/sync` rejoue la file dans l'ordre d'émission. Chaque
    opération porte une référence d'idempotence — un lot se renvoie sans crainte. Un refus ne fait pas
    tomber le reste du lot.
  - **Sort visible** : bandeau permanent (ce qui reste à remonter) + écran `/voyage/:id/operations`,
    qui montre chaque opération et son sort, motif de refus compris. C'est la contrepartie assumée du
    choix optimiste côté serveur : un billet dont le siège a été évincé doit se **voir**.
  - **Interdit hors ligne** : désistement (remboursement — caisse de gare), modification d'un billet,
    réservation, récompense de fidélité (deux appareils brûleraient la même).
- **À venir** : bilan de recette **par période** (aujourd'hui / 7j / 30j) incluant les voyages
  clôturés — nécessite un endpoint perso côté backend (`/api/stats/commercial` étant réservé à
  l'admin) ; fidélité à la vente.

## Développement

```bash
dart run build_runner watch --delete-conflicting-outputs   # régénération continue
flutter analyze
```

Après toute modification d'un modèle `@freezed`, relancer `build_runner`.




## Brouillon

Ça change tout — et ça confirme exactement la discordance que j'avais repérée. Un **admin de gare** (`ROLE_ADMIN_GARE`) est autorisé à vendre côté backend par un **bypass** (l'entité `Ticket` est gare-scoped), **sans** permission `Ticket/CREER` explicite. Or le `can()` de l'app ne reproduit **pas** ce bypass :

```dart
bool get isAdmin => roles.contains('ROLE_ADMIN') || roles.contains('ROLE_SUPER_ADMIN'); // ROLE_ADMIN_GARE absent !
bool can(String entity, String action) {
  if (isAdmin) return true;
  return permissions.any(...); // → false pour un admin gare sans permission explicite
}
```

→ backend autorise la vente, mais l'app **masque le bouton**. Je vérifie sur données réelles : comment `ROLE_ADMIN_GARE` est attribué, et l'admin-gare de test a-t-il (ou non) la permission explicite ?

Un seul rôle RBAC existe, et l'utilisateur 3 (commercial des voyages 24/26/34) n'a **aucun** `user_role` → il est autorisé autrement. Je regarde `User::getRoles()` (dérivation de `ROLE_ADMIN_GARE`) et l'utilisateur 3 :

`getRoles()` = colonne `roles` + `ROLE_USER`, et `/api/me` sérialise ça. Donc un admin de gare reçoit `roles: ["ROLE_ADMIN_GARE","ROLE_USER"]` mais **sans** permission `Ticket/CREER` (il compte sur le bypass) → `can()` = false → bouton masqué. Je confirme sur l'utilisateur 3 (l'admin de gare de test) :

**Bug confirmé sur données réelles.** L'utilisateur 3 (`llll@gmail.com`, l'admin de gare affecté comme commercial) : `roles: ["ROLE_USER","ROLE_ADMIN_GARE"]`, `userRoles: []` (aucune permission explicite). Donc côté app : `isAdmin`=false (pas ROLE_ADMIN), permissions vides → `can('Ticket','CREER')`=false → **bouton masqué**. Alors que le backend l'autorise (bypass admin-gare sur `Ticket` gare-scoped).

Le correctif : le `can()` de l'app doit **refléter le backend** (bypass admin-gare pour les entités gare-scoped). Je récupère la liste exacte et je regarde tous les usages de `can()`/`isAdmin` :

**Cause racine confirmée et généralisée** : la liste backend est `['Voyage','Ticket','Reservation','Courrier','Bagage','User','Role']`, et TOUS les `can()` de l'app portent sur des entités gare-scoped (`Ticket`, `Bagage`). Donc pour un admin de gare commercial, **tout est cassé** (vendre, modifier billet, créer/modifier bagage) — un seul correctif règle tout : faire refléter le bypass admin-gare par `can()`.

J'applique le correctif dans le modèle :

Correctif appliqué. Je nettoie la commande de diagnostic jetable (banc d'essai) et je vérifie que le Dart compile :

Corrigé et vérifié (`flutter analyze` : aucun problème). Banc d'essai nettoyé (commande de diagnostic supprimée, cache backend vidé).

## Le bug — cause racine (prouvée sur données réelles)

Ce n'était **pas** côté backend : le backend autorise bien la vente. C'était une **désynchronisation entre le `can()` de l'app et le `PermissionVoter` du backend**.

Le backend accorde à un **`ROLE_ADMIN_GARE`** un *bypass* sur les entités **bornées par sa gare** (`Voyage, Ticket, Reservation, Courrier, Bagage, User, Role`) — **sans permission explicite**. Or l'app ne reproduisait ce bypass **que** pour `ROLE_ADMIN`/`ROLE_SUPER_ADMIN` :

```dart
bool get isAdmin => roles.contains('ROLE_ADMIN') || roles.contains('ROLE_SUPER_ADMIN'); // ROLE_ADMIN_GARE absent
bool can(entity, action) { if (isAdmin) return true; return permissions.any(...); }
```

**Preuve** — l'admin de gare que tu as affecté (`llll@gmail.com`, id 3) : `/api/me` renvoie `roles: ["ROLE_USER","ROLE_ADMIN_GARE"]` et **`userRoles: []`** (aucune permission RBAC). Donc `can('Ticket','CREER')` → `isAdmin` faux + permissions vides → **false** → bouton masqué. Alors que `peutVendre` était bien vrai (voyage actif, car affecté, position ≠ terminus). (Le commercial « normal » noura, id 5, a une permission `Ticket/CREER` explicite → chez elle le bouton s'affichait.)

## Les autres bugs (même cause) — repérés et corrigés d'un coup

Le même `can()` bloquait, pour un admin de gare commercial, **tout** ce qui touche aux entités gare-scoped :
- `voyage_detail_page` → **Vendre un billet** (le symptôme signalé) ;
- `mes_ventes_page` → **modifier un billet**, **créer un bagage**, **modifier un bagage** ;
- `vente_page` → **créer un bagage**.

## Le correctif

Dans [auth_user.dart](commercialflutter/lib/features/auth/data/models/auth_user.dart), j'ai fait **refléter le backend** par `can()` : un `ROLE_ADMIN_GARE` bypasse pour les entités bornées par sa gare (liste = miroir exact de `GareScopedEntities::ENTITIES`).

```dart
if (roles.contains('ROLE_ADMIN_GARE') && _gareScopedEntities.contains(e)) return true;
```

Un seul changement (logique métier du modèle, **pas** de code généré → pas besoin de `build_runner`) répare les 5 actions ci-dessus.

## À faire pour voir l'effet
Relance/hot-restart l'app (`flutter run`) et reconnecte-toi avec l'admin de gare : le bouton **Vendre un billet** apparaît, ainsi que les actions bagage/billet.

## Points d'attention honnêtes
- La liste des entités gare-scoped est désormais **dupliquée** (backend ↔ app). Je l'ai commentée comme « miroir exact » pour rendre la dépendance explicite : si tu modifies `GareScopedEntities::ENTITIES` côté backend, pense à mettre à jour cette liste.
- Je n'ai **pas** touché au backend (il est correct) ni à la base. Le correctif est purement côté app.