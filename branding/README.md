### Icône de commercialflutter

- **Le plan des sièges**, fond brun `#78350F`, tracé blanc, un siège ambre `#F59E0B`
    > C'est l'écran où le vendeur passe sa journée, et le siège ambre dit « vendu »
    > FOND BRUN et non ambre, contrairement aux applications de réservation : les deux publics sont disjoints (l'agent à bord, le client) et rien ne doit laisser un commercial installer l'application cliente. Même dessin de marque, fond opposé — `Frontend-Transport/public/icons` garde l'ambre du back-office
    > Trois propositions non retenues sont gardées dans `propositions/` avec leur aperçu : `c1-ligne` (la ligne et ses arrêts en négatif), `c3-recu` (le reçu imprimé), `c4-car` (le car vu de face)

- **Régénérer** : `python branding/generer.py`
    > Chrome sans interface rend le SVG à 1024 px, Pillow réduit en LANCZOS. Un export direct en petite taille crénelle le trait — même chaîne que les icônes du back-office
    > Produit les mipmaps Android (48 → 192), l'icône adaptative (`ic_launcher_foreground` + `ic_launcher_monochrome` 108 → 432, `mipmap-anydpi-v26/ic_launcher.xml`, `values/ic_launcher_background.xml`), les 16 fichiers de `AppIcon.appiconset` et les icônes web
    > Les tailles iOS sont LUES dans `Contents.json`, jamais recopiées : Xcode refuse le catalogue dès qu'un fichier déclaré manque ou tombe à côté

- **Changer d'icône**
    > Copier un `propositions/<nom>/icon.svg` par-dessus `icon.svg`, adapter `icon-monochrome.svg`, relancer le script. Rien d'autre à toucher, sauf `web/manifest.json` si la couleur de fond change (`background_color` et `theme_color` y sont redits)
    > CONVENTION DU SVG : un `<rect id="fond">` porte l'aplat, un `<g id="dessin">` porte le tracé. Le script s'en sert pour fabriquer les variantes — sans fond pour l'adaptatif, recadrées pour les zones sûres
    > `icon-monochrome.svg` est la SILHOUETTE du même dessin, aux MÊMES COORDONNÉES : le script lui applique le cadrage mesuré sur le dessin principal, parce que les deux calques se superposent dans le lanceur. Une mesure séparée les décalerait dès que la silhouette diffère d'un pixel

- **Les pièges tenus par le script**
    > !! LA ZONE SÛRE D'ANDROID EST UN RAYON, PAS UNE LARGEUR. Le lanceur rogne l'icône adaptative avec un masque dont le pire cas est un CERCLE : c'est la demi-diagonale du dessin qui doit tenir dans les 66 dp centraux d'un canevas de 108 dp, soit un rayon de 0,3055. L'échelle est donc MESURÉE sur un rendu sans fond (`encombrement()`) et non écrite à la main — un premier jet qui réduisait le canevas de 34 % laissait le tracé à 33 % de la largeur, la moitié de ce qu'Android attend, et l'erreur aurait suivi chaque nouveau dessin
    > !! iOS REFUSE LA TRANSPARENCE sur une icône d'application : le paquet est rejeté à l'envoi. Les fichiers de `AppIcon.appiconset` sont aplatis sur la couleur de fond, les autres gardent leur canal alpha
