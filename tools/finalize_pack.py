#!/usr/bin/env python3
"""Genera los .pw.toml de los JAR que NO están en Modrinth/CurseForge (carpeta localmods/) apuntando a la URL pública del
repositorio donde se alojen, y refresca el índice de packwiz.

Uso: python3 -I finalize_pack.py <proyecto-packwiz> <URL-base-raw> [packwiz]
  <URL-base-raw>  p. ej. https://raw.githubusercontent.com/USUARIO/REPO/main   (sin barra final)
Lados: SomitaMultiverCore solo en el servidor; el resto en ambos.
"""
import glob
import hashlib
import os
import re
import subprocess
import sys
import urllib.parse

SERVER_ONLY = ("SomitaMultiverCore",)


def main():
    pack, base = sys.argv[1], sys.argv[2].rstrip("/")
    packwiz = sys.argv[3] if len(sys.argv) > 3 else "packwiz"
    os.makedirs(os.path.join(pack, "mods"), exist_ok=True)
    for jar in sorted(glob.glob(os.path.join(pack, "localmods", "*.jar"))):
        name = os.path.basename(jar)
        data = open(jar, "rb").read()
        sha256 = hashlib.sha256(data).hexdigest()
        slug = re.sub(r"[^a-z0-9]+", "-", re.sub(r"\.jar$", "", name, flags=re.I).lower()).strip("-")[:60]
        side = "server" if name.startswith(SERVER_ONLY) else "both"
        url = f"{base}/localmods/{urllib.parse.quote(name)}"
        text = (f'name = "{name}"\nfilename = "{name}"\nside = "{side}"\n\n[download]\nurl = "{url}"\n'
                f'hash-format = "sha256"\nhash = "{sha256}"\n')
        open(os.path.join(pack, "mods", slug + ".pw.toml"), "w", encoding="utf-8", newline="\n").write(text)
        print(f"  {name} -> mods/{slug}.pw.toml ({side})")
    subprocess.run([packwiz, "refresh"], cwd=pack, check=True)


if __name__ == "__main__":
    main()
