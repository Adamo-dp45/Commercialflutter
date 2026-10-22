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
  **départ/siège**, tarif, code voyage, **QR** code billet, souche) et bagage
  (`mails/bagage/ticket.html.twig`).
  Code partagé et autonome : [`core/pdf/recu_pdf.dart`](lib/core/pdf/recu_pdf.dart),
  [`core/pdf/bagage_recu_pdf.dart`](lib/core/pdf/bagage_recu_pdf.dart).
  - **LE BILLET ET LE REÇU DE BAGAGE VIENNENT DU SERVEUR** (20/10/2026,
    [`core/pdf/impression_distante.dart`](lib/core/pdf/impression_distante.dart)) : la maquette était
    composée ici, dans le front web et dans les deux apps de réservation — quatre versions du même
    papier, dans trois langages. Elle vit désormais auprès de ses données et l'API la rend pour tous
    les canaux (`GET /api/tickets/{id}/print`, `GET /api/bagages/{id}/print`).
    - !! `recu_pdf.dart` et `bagage_recu_pdf.dart` RESTENT, comme REPLI hors-ligne : le commercial
      vend et imprime sans réseau, à bord du car. C'est la limite irréductible de la règle « une
      seule source » — on passe de quatre rendus à deux, pas à un.
    - DEUX situations amènent au repli, à ne pas confondre : le document n'a pas d'IDENTIFIANT
      SERVEUR (vente hors ligne : il n'y a rien à demander, même avec du réseau), ou l'appel ÉCHOUE
      faute de réseau. La bascule se décide sur l'échec réel (`ApiException.estHorsLigne`), jamais
      sur l'état déclaré du réseau — un téléphone accroché à une antenne sans débit se dit connecté.
    - Toute AUTRE erreur remonte : composer un papier en réponse à un refus du serveur reviendrait
      à imprimer ce qu'il vient d'interdire.
    - `BagageCree` porte désormais son `id` (nul après une création hors ligne) : sans lui, le reçu
      ne pouvait pas être demandé à l'API.
    - Sentinelles : [`test/impression_distante_test.dart`](test/impression_distante_test.dart),
      vérifiées discriminantes. Elles tiennent la DÉCISION DE BASCULE, qui ne se voit nulle part à
      l'écran : un billet du serveur et un billet composé ici se ressemblent, et l'on ne s'en
      apercevrait qu'au comptoir, des semaines plus tard, devant deux papiers différents.
  - **« MON IMPRIMANTE » : LE FORMAT EST UN RÉGLAGE DE L'APPAREIL** (21/10/2026,
    [`core/pdf/format_impression.dart`](lib/core/pdf/format_impression.dart)) : le billet sort sur
    deux matériels — la thermique de 80 mm, et les terminaux à rouleau large (du genre A5) de
    certaines gares, sur lesquels un billet composé pour 80 mm paraît minuscule au milieu de la
    page. L'API sait rendre les deux (`?format=large`) ; il manquait de dire lequel. Le choix se
    fait dans le menu du compte, à l'accueil, et vit dans le téléphone.
    - LE SERVEUR NE PEUT PAS LE DEVINER : le format ne dépend ni de l'entreprise, ni de la gare, ni
      du voyage, mais de la MACHINE posée devant l'agent — deux vendeurs d'une même gare peuvent
      avoir deux imprimantes. D'où un réglage local, et non une colonne en base.
    - !! LE FORMAT SE DÉCIDE DANS `RecuImprimable`, pas chez les trois écrans qui impriment. Un
      oubli dans l'un d'eux sortirait un papier étroit sur un terminal large sans que rien ne le
      signale. Une SENTINELLE tient le câblage du provider en plus de la classe : sans elle, un
      `RecuImprimable` qui sait lire le réglage mais ne le reçoit jamais resterait vert.
    - Le format est LU À CHAQUE IMPRESSION, dans le stockage, et non gardé en mémoire : un état
      chargé en arrière-plan vaudrait « thermique » le temps de son chargement, et un billet émis
      dans cet intervalle sortirait au mauvais format.
    - LE RÉGLAGE COMMANDE LES QUATRE PAPIERS (21/10/2026) : le billet et le reçu de bagage du
      serveur, et les deux mêmes composés ICI hors ligne. Il ne valait d'abord que pour le billet
      du serveur — un vendeur réglé sur un terminal large retrouvait donc l'écriture minuscule dès
      qu'il perdait le réseau, c'est-à-dire en route, là où il vend le plus ; et son reçu de bagage
      sortait étroit même avec du réseau.
      - `FormatImpression` porte LA MÊME TABLE que le serveur — échelle 1,8 contre 1, laize de
        148 mm contre 80, marge horizontale de 6 mm contre 4,5 — pour que les deux papiers se
        ressemblent, qu'ils viennent de l'API ou du téléphone. La marge ne suit pas l'échelle :
        elle décrit la zone que la tête sait écrire, pas la taille du texte.
      - **CETTE TABLE EST SOUS CONTRAT DEPUIS LE 21/10/2026**
        (`Backend-Transport/tests/Domain/ContratImpressionTest.php`, qui lit ce fichier et le
        confronte aux constantes de `PdfService`). Le serveur est l'autorité : c'est lui qui rend
        le même billet pour le guichet et le web. Font contrat la LAIZE, la MARGE HORIZONTALE et
        l'ÉCHELLE ; la marge VERTICALE non — ici la hauteur de page est libre et c'est le contenu
        qui l'arrête, là-bas elle est fixe parce que le pilote coupe à chaque page.
      - !! **LES DEUX TABLES AVAIENT DÉJÀ DIVERGÉ** : la marge horizontale du thermique valait
        12 pt (4,233 mm) contre 4,5 mm côté serveur. Les deux tenaient dans la zone imprimable de
        l'EPSON TM-T20III (3,753 → 75,949 mm), mais celle-ci n'y gardait que 0,18 mm de garde à
        droite contre 0,45. Alignée sur le serveur. Un `marginAll: 5 mm` mort est parti au
        passage : `pw.Page` reçoit son propre `margin`, qui écrase celui du format.
      - !! LES SENTINELLES MESURENT LE PDF, PAS LE CODE (`test/recu_pdf_test.dart`). Deux choses
        doivent bouger ENSEMBLE, et rien ne le dit à l'écran : la largeur de page (une page large
        avec une écriture de 80 mm laisse le billet dans un coin) et la taille des caractères (une
        écriture agrandie sur 80 mm déborde de la laize). D'où deux mesures — le `/MediaBox`, qui
        est en clair, et l'opérateur `Tf` des flux compressés — et non une.
      - La feuille de réglage a sa propre sentinelle d'écran
        ([`test/feuille_format_impression_test.dart`](test/feuille_format_impression_test.dart), la
        première du projet) : un choix qui ne s'enregistre pas laisserait tout le dispositif
        derrière sans que rien ne tombe au rouge. C'est pour elle que le réglage passe par
        `MagasinReglage` — `FlutterSecureStorage` lève en test, faute de canal de plate-forme.
    - POURQUOI PAS LE DIALOGUE SYSTÈME (`Printing.layoutPdf`), qui donnerait le format réellement
      choisi : il remplacerait le geste « Partager » — par lequel le vendeur envoie aussi le billet
      en WhatsApp —, ajouterait un écran à chaque vente et exigerait l'appel réseau PENDANT le
      dialogue, là où le repli doit répondre tout de suite. Le matériel ne change pas en cours de
      journée.
  - **LA SOUCHE DU BILLET PART SUR SA PROPRE PAGE** (20/10/2026, `recu_pdf.dart`) : une imprimante
    thermique n'a pas de peigne de perforation, seulement une lame, et cette lame ne tombe qu'en FIN
    DE PAGE. Deux pages est donc le seul moyen d'obtenir le billet « presque coupé » que le
    commercial détache sans le déchirer. Même dispositif que le web, vérifié sur une EPSON TM-T20III.
    - Le terminal doit être réglé en ROULEAU CONTINU avec « Paper Cut » sur `Page[Alim., Coup.]`.
      `buildRecuPdf(d, soucheDetachable: false)` ramène tout sur une page : le recours pour un pilote
      qui coupe par document, où la seconde page ne ferait qu'avancer le papier.
    - Contrairement au PDF du web, les deux pages ont ici CHACUNE leur hauteur : le format rouleau du
      paquet `pdf` n'impose pas de hauteur de page, elle s'arrête au contenu. Le repère
      « DETACHER ICI » reste imprimé dans les deux modes — sans coupe à chaque page, c'est le seul guide.
    - Sentinelles : [`test/recu_pdf_test.dart`](test/recu_pdf_test.dart), vérifiées discriminantes. Elles
      contiennent le patron pour LIRE un PDF produit par le paquet `pdf` : les flux sont COMPRESSÉS
      (zlib, et le saut de ligne qui suit `stream` n'en fait pas partie) et le texte est découpé MOT PAR
      MOT (`[(DETACHER)]TJ … [(ICI)]TJ`) — chercher une phrase entière dans les octets bruts ne trouve
      jamais rien.
  - **NUMÉRO DE DÉPART DU JOUR** (`VoyageCommercial.numerodepart`, servi par
    `/api/voyages/me/commercial` **et par l'instantané**) : « Départ 2 », le repère que le vendeur
    annonce et que le passager entend. La case face au siège portait le code voyage, elle porte
    désormais **« DEPART 4 · SIEGE 29 »** — recalé sur le ticket de référence, exactement comme le
    thermique du web ; le code voyage a pris la ligne du **véhicule**, dont l'affichage est
    **conservé en commentaire** (billet ET souche). Affiché aussi sur la carte d'un départ et dans
    la barre de titre de sa fiche (`VoyageCommercial.libelleDepart`).
  - !! un cache de départs écrit par une version ANTÉRIEURE n'a pas le numéro : le reçu retombe
    alors sur « - » et le libellé sur le seul code voyage, plutôt que d'afficher « Départ null ».
    Le premier chargement avec réseau le remplit. L'**étiquette bagage** est volontairement
    inchangée : elle porte déjà « DEPART » pour la GARE de départ, deux sens sous un même mot sur
    un ticket de 80 mm se liraient mal — et le code voyage y identifie déjà le départ.
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
  - **CONTRÔLE D'EMBARQUEMENT PAR SCAN** (19/10/2026, `lib/features/controle/`) : depuis la fiche
    d'un départ, la caméra lit le QR d'un billet et l'écran répond en trois états — valide, déjà
    scanné, invalide — en couleur, avec le nom et le siège du passager, plus un retour haptique
    distinct pour que l'agent n'ait pas à regarder l'écran. C'est la fiche B2 de la feuille de
    route ; le serveur fait tout le jugement (`POST /api/tickets/pointer`).
    - !! **CET ÉCRAN EXIGE DU RÉSEAU, et c'est le seul de l'application.** Le téléphone ne détient
      ni le secret qui signe les QR, ni l'état d'embarquement des autres contrôles : il ne peut donc
      ni reconnaître un faux, ni voir qu'un billet est déjà monté. Promettre un verdict hors ligne
      serait promettre ce qu'on ne peut pas tenir. On le DIT (`EtatPointage.indisponible`, en gris
      et **jamais en rouge**), et le chauffeur pointe au stylo sur son bordereau — ce qu'il faisait
      de toute façon hier. Choix arrêté avec l'utilisateur le 19/10/2026, contre l'option « pointer
      dans la file », qui aurait laissé passer un duplicata jusqu'à la synchronisation.
    - La bascule se lit sur l'ÉCHEC RÉEL de l'appel (`ApiException.estHorsLigne`), pas sur l'état
      déclaré du réseau : même règle que la vente, un téléphone accroché à une antenne sans débit
      se dit connecté.
    - **Un état inconnu devient « indisponible », jamais « invalide »** : un serveur plus récent ou
      une réponse tronquée ne doivent pas faire refuser un passager qui a payé.
    - **VERROU DE 3 s PAR CODE** (`VerrouScan`, testé) : une caméra relit le même QR plusieurs fois
      par seconde. Sans lui, le premier envoi marque l'embarquement et les suivants reviennent
      « déjà scanné » sous les yeux de l'agent, qui croit à un duplicata et arrête quelqu'un en
      règle. Le verrou porte sur UN CODE, pas sur le scanner : deux billets d'affilée passent
      tous les deux — c'est le cas d'une famille qui embarque.
    - **La saisie manuelle n'est pas un pis-aller** : un QR froissé, mouillé ou imprimé trop pâle
      ne se lit pas, et le passager est devant l'agent.
    - PERMISSIONS : Android vient de `mobile_scanner` lui-même (`CAMERA`, et `camera` en
      `required="false"` — un téléphone sans caméra peut toujours installer l'application et saisir
      à la main). iOS exige `NSCameraUsageDescription` dans `Info.plist`, ajouté ici : sans lui,
      l'application ne demande pas la permission, elle **s'arrête** au premier scan.
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
# !! sur ce poste, la compilation AOT du script de build est bloquée par une stratégie de contrôle
# d'application Windows (« gen_snapshot.exe »). Ajouter --force-jit pour passer outre :
#   dart run build_runner build --delete-conflicting-outputs --force-jit
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

**Le `can()` de `AuthUser` LIT les droits que le serveur accorde** (21/10/2026). `GET /api/me` sert
`permissions: {tout, accordees}` — `tout` pour l'administrateur d'entreprise, `accordees` une liste
de `entite:ACTION` — et [`DroitsEffectifs`](lib/features/auth/data/models/droits_effectifs.dart) y
cherche. L'application ne reproduit plus aucune règle d'accès.

- CE QU'ELLE FAISAIT AVANT : `can()` était un MIROIR du `PermissionVoter`, avec le bypass
  administrateur, celui de l'admin de gare et la liste `_gareScopedEntities` recopiée à la main. Le
  front web en gardait une copie identique. Quatre écritures de la même règle, qu'aucun code
  n'obligeait à rester d'accord.
- !! **ET ELLES AVAIENT DÉJÀ DIVERGÉ** : `isAdmin` comptait ici `ROLE_SUPER_ADMIN`, à qui le
  serveur n'accorde AUCUN droit métier (il n'a pas d'entreprise, donc aucune permission ne le
  concerne). Sans conséquence pratique — un super administrateur n'ouvre pas l'app du vendeur —
  mais c'est bien ce que la duplication produit quand personne ne la surveille. Mesuré le
  21/10/2026 ; détail au README du backend, module `Administration`.
- **AUCUN REPLI SUR UN CALCUL LOCAL.** Il a été gardé quelques heures — un profil mis en cache par
  une version antérieure ne porte pas le champ, et le vendeur aurait vu tous ses boutons
  disparaître — puis supprimé : l'application n'est pas en production, aucun cache ancien ne
  circule, et une seconde écriture de la règle « au cas où » aurait rouvert ce que ce chantier
  ferme. Un profil absent ou abîmé n'accorde RIEN ; la reconnexion le répare. Le modèle
  `Permission`, l'aplatissement des `userRoles` et `isAdmin` sont partis avec, faute de lecteur.
- Sentinelles : `test/models_test.dart`, qui tient les deux chemins — et notamment qu'un compte
  portant `ROLE_SUPER_ADMIN` et `ROLE_ADMIN_GARE` n'obtient RIEN si le profil servi n'accorde rien.
