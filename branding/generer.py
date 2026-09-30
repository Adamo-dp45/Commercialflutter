"""Régénère toutes les icônes de l'application à partir de branding/icon.svg.

    python branding/generer.py

CHAÎNE DE RENDU : Chrome sans interface rend le SVG à 1024 px, Pillow réduit en
LANCZOS. Un export direct en petite taille crénelle le trait — c'est la même
chaîne que les icônes du back-office (cf. Frontend-Transport/public/icons).

POUR CHANGER D'ICÔNE : copier un branding/propositions/<nom>/icon.svg par-dessus
branding/icon.svg, adapter branding/icon-monochrome.svg (la silhouette, dessin
plein sans couleur), puis relancer ce script. Rien d'autre à toucher.

CONVENTION DU SVG SOURCE : un `<rect id="fond">` porte l'aplat de couleur, un
`<g id="dessin">` porte le tracé. Le script s'en sert pour fabriquer les
variantes — sans fond pour l'adaptatif Android, réduites pour les zones sûres.
"""

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

RACINE = Path(__file__).resolve().parent.parent
BRANDING = RACINE / "branding"

RENDU = 1024

# RAYONS SÛRS, exprimés en unités du viewBox (512). Ce sont des RAYONS et non des
# largeurs : le lanceur Android rogne l'icône adaptative avec un masque dont le
# pire cas est un CERCLE, donc c'est la demi-diagonale du dessin qui doit y tenir,
# pas sa largeur. Android ne montre que les 66 dp centraux d'un canevas de 108 dp,
# soit un rayon de 0,3055 ; le maskable du web garantit 80 % du côté, soit 0,40.
RAYON_ADAPTATIF = 0.3055 * 512
RAYON_MASKABLE = 0.40 * 512

DENSITES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def chrome() -> str:
    candidats = [
        os.environ.get("CHROME"),
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        shutil.which("chrome"),
        shutil.which("google-chrome"),
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    ]
    for c in candidats:
        if c and Path(c).exists():
            return c
    sys.exit("Chrome introuvable : renseigner la variable d'environnement CHROME.")


def variante(svg: str, fond: bool = True) -> str:
    return svg if fond else re.sub(r'<rect id="fond"[^>]*/>', "", svg)


def encombrement(svg: str) -> tuple:
    """Centre et demi-diagonale du DESSIN SEUL, mesurés sur un rendu sans fond.

    MESURÉ et non supposé : une échelle écrite à la main vaut pour le dessin
    qu'on avait sous les yeux et devient fausse à la proposition suivante — le
    premier jet réduisait le canevas de 34 %, ce qui laissait le tracé à 33 % de
    la largeur quand Android en attend le double."""
    boite = rendre(variante(svg, fond=False)).split()[3].getbbox()
    if boite is None:
        return 256.0, 256.0, 256.0
    x0, y0, x1, y1 = (valeur * 512 / RENDU for valeur in boite)
    demi = ((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5 / 2
    return (x0 + x1) / 2, (y0 + y1) / 2, demi


def cadrer(svg: str, mesure: tuple, rayon: float, fond: bool = True) -> str:
    """Recentre et met le dessin à l'échelle pour qu'il tienne dans `rayon`.
    Jamais d'agrandissement : un dessin déjà à l'aise garde sa taille."""
    cx, cy, demi = mesure
    echelle = min(1.0, rayon / demi)
    return variante(svg, fond).replace(
        '<g id="dessin">',
        f'<g id="dessin" transform="translate(256 256) scale({echelle:.4f}) '
        f'translate({-cx:.2f} {-cy:.2f})">',
    )


def rendre(svg: str) -> Image.Image:
    with tempfile.TemporaryDirectory() as tmp:
        src, out = Path(tmp) / "i.svg", Path(tmp) / "i.png"
        src.write_text(svg, encoding="utf-8")
        subprocess.run(
            [
                chrome(), "--headless", "--disable-gpu", "--hide-scrollbars",
                "--force-device-scale-factor=1",
                "--default-background-color=00000000",
                f"--window-size={RENDU},{RENDU}",
                f"--screenshot={out}", str(src),
            ],
            check=True, capture_output=True,
        )
        return Image.open(out).convert("RGBA")


def couleur_fond(svg: str) -> tuple:
    trouve = re.search(r'<rect id="fond"[^>]*fill="#([0-9A-Fa-f]{6})"', svg)
    valeur = trouve.group(1) if trouve else "FFFFFF"
    return tuple(int(valeur[i:i + 2], 16) for i in (0, 2, 4))


def ecrire(source: Image.Image, taille: int, chemin: Path, opaque=None) -> None:
    """Réduit puis écrit. `opaque` aplatit sur cette couleur : iOS REFUSE la
    transparence sur une icône d'application, le paquet est rejeté à l'envoi."""
    chemin.parent.mkdir(parents=True, exist_ok=True)
    image = source.resize((taille, taille), Image.LANCZOS)
    if opaque is not None:
        plat = Image.new("RGB", image.size, opaque)
        plat.paste(image, mask=image.split()[3])
        image = plat
    image.save(chemin)
    print(f"  {chemin.relative_to(RACINE).as_posix()}  {taille}px")


def main() -> None:
    svg = (BRANDING / "icon.svg").read_text(encoding="utf-8")
    fond = couleur_fond(svg)

    print("Rendu des variantes...")
    mesure = encombrement(svg)
    print(f"  dessin : centre ({mesure[0]:.0f}, {mesure[1]:.0f}), "
          f"demi-diagonale {mesure[2]:.0f}/256")
    plein = rendre(variante(svg))
    masque = rendre(cadrer(svg, mesure, RAYON_MASKABLE))
    premier_plan = rendre(cadrer(svg, mesure, RAYON_ADAPTATIF, fond=False))

    # Le monochrome reprend le cadrage du dessin PRINCIPAL et non le sien : les
    # deux calques se superposent dans le lanceur, une mesure séparée les
    # décalerait dès que la silhouette diffère d'un pixel.
    source_mono = BRANDING / "icon-monochrome.svg"
    mono = (
        rendre(cadrer(source_mono.read_text(encoding="utf-8"), mesure,
                      RAYON_ADAPTATIF, fond=False))
        if source_mono.exists() else None
    )

    print("Android")
    res = RACINE / "android/app/src/main/res"
    for dpi, facteur in DENSITES.items():
        ecrire(plein, round(48 * facteur), res / f"mipmap-{dpi}/ic_launcher.png")
        ecrire(premier_plan, round(108 * facteur),
               res / f"mipmap-{dpi}/ic_launcher_foreground.png")
        if mono:
            ecrire(mono, round(108 * facteur),
                   res / f"mipmap-{dpi}/ic_launcher_monochrome.png")

    ligne_mono = (
        '\n    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>'
        if mono else ""
    )
    (res / "mipmap-anydpi-v26").mkdir(parents=True, exist_ok=True)
    (res / "mipmap-anydpi-v26/ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>'
        f'{ligne_mono}\n'
        '</adaptive-icon>\n',
        encoding="utf-8",
    )
    (res / "values").mkdir(parents=True, exist_ok=True)
    (res / "values/ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">#{"%02X%02X%02X" % fond}</color>\n'
        '</resources>\n',
        encoding="utf-8",
    )
    print("  mipmap-anydpi-v26/ic_launcher.xml + values/ic_launcher_background.xml")

    print("iOS")
    # Les tailles viennent de Contents.json et ne sont PAS recopiées ici : Xcode
    # refuse le catalogue dès qu'un fichier déclaré manque ou tombe à côté.
    appicon = RACINE / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((appicon / "Contents.json").read_text(encoding="utf-8"))
    for image in contents["images"]:
        if "filename" not in image:
            continue
        cote = float(image["size"].split("x")[0]) * float(image["scale"].rstrip("x"))
        ecrire(plein, round(cote), appicon / image["filename"], opaque=fond)

    print("Web")
    web = RACINE / "web"
    ecrire(plein, 192, web / "icons/Icon-192.png")
    ecrire(plein, 512, web / "icons/Icon-512.png")
    ecrire(masque, 192, web / "icons/Icon-maskable-192.png")
    ecrire(masque, 512, web / "icons/Icon-maskable-512.png")
    ecrire(plein, 32, web / "favicon.png")

    print("Aperçus des propositions")
    for dossier in sorted((BRANDING / "propositions").iterdir()):
        if (dossier / "icon.svg").exists():
            ecrire(rendre((dossier / "icon.svg").read_text(encoding="utf-8")),
                   512, dossier / "apercu.png")


if __name__ == "__main__":
    main()
