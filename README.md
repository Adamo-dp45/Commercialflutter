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
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

- `API_BASE_URL` : racine du backend Symfony/API Platform (sans `/api`).
  `10.0.2.2` = l'hôte local vu depuis l'émulateur Android ; sur un appareil physique, mettez l'IP LAN
  de la machine (ex. `http://192.168.1.20:8000`). Pas de slug : le périmètre entreprise vient du compte.

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
- **À venir** : bilan de recette **par période** (aujourd'hui / 7j / 30j) incluant les voyages
  clôturés — nécessite un endpoint perso côté backend (`/api/stats/commercial` étant réservé à
  l'admin) ; fidélité à la vente ; vente hors-ligne (file d'attente + resync, cf. plan reporté).

## Développement

```bash
dart run build_runner watch --delete-conflicting-outputs   # régénération continue
flutter analyze
```

Après toute modification d'un modèle `@freezed`, relancer `build_runner`.
