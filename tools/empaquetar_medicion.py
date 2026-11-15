# Empaqueta el kit de medicion para el director: el .exe de medicion, su .pck,
# MEDIR.bat y override.cfg, todo en una carpeta y en un zip.
# Uso: python tools/empaquetar_medicion.py
import os
import shutil
import zipfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGEN = os.path.join(RAIZ, "build")
DESTINO = os.path.join(ORIGEN, "medicion")
ZIP = os.path.join(ORIGEN, "medicion.zip")

FICHEROS = [
    ("BugDeFamilia_medir.exe", os.path.join(ORIGEN, "BugDeFamilia_medir.exe")),
    ("BugDeFamilia_medir.pck", os.path.join(ORIGEN, "BugDeFamilia_medir.pck")),
    ("MEDIR.bat", os.path.join(RAIZ, "tools", "medir_windows", "MEDIR.bat")),
    ("override.cfg", os.path.join(RAIZ, "tools", "medir_windows", "override.cfg")),
]


def main() -> int:
    faltan = [nombre for nombre, ruta in FICHEROS if not os.path.isfile(ruta)]
    if faltan:
        print("ERROR: faltan estos ficheros: %s" % ", ".join(faltan))
        return 1
    if os.path.isdir(DESTINO):
        shutil.rmtree(DESTINO)
    os.makedirs(DESTINO)
    for nombre, ruta in FICHEROS:
        shutil.copy2(ruta, os.path.join(DESTINO, nombre))
    if os.path.isfile(ZIP):
        os.remove(ZIP)
    with zipfile.ZipFile(ZIP, "w", zipfile.ZIP_DEFLATED) as archivo:
        for nombre, _ in FICHEROS:
            archivo.write(os.path.join(DESTINO, nombre), nombre)
    print("Carpeta: %s" % DESTINO)
    print("Zip: %s (%.1f MB)" % (ZIP, os.path.getsize(ZIP) / 1048576.0))
    print("Contenido:")
    for nombre, _ in FICHEROS:
        print("  - %s" % nombre)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
