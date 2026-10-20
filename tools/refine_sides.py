#!/usr/bin/env python3
"""Ajusta 'side' en los .pw.toml con origen Modrinth: si el mod es obligatorio en el cliente y OPCIONAL en el servidor
(client_side=required, server_side=optional) se marca como solo-cliente, para no cargarlo inútilmente en el servidor.
Uso: python3 -I refine_sides.py <proyecto-packwiz> [slug-extra-solo-cliente ...]"""
import glob
import json
import os
import re
import sys
import urllib.parse
import urllib.request

pack = sys.argv[1]
extra_client = set(sys.argv[2:])
metas = {}
for f in glob.glob(os.path.join(pack, "mods", "*.pw.toml")):
    t = open(f, encoding="utf-8").read()
    m = re.search(r'mod-id = "([^"]+)"', t)
    if m:
        metas[m.group(1)] = f
ids = sorted(metas)
changed = []
for i in range(0, len(ids), 100):
    chunk = ids[i:i + 100]
    url = "https://api.modrinth.com/v2/projects?ids=" + urllib.parse.quote(json.dumps(chunk))
    for p in json.load(urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "somita-pack/0.1"}))):
        f = metas[p["id"]]
        t = open(f, encoding="utf-8").read()
        if 'side = "both"' in t and p.get("client_side") == "required" and p.get("server_side") == "optional":
            open(f, "w", encoding="utf-8", newline="\n").write(t.replace('side = "both"', 'side = "client"', 1))
            changed.append(p["title"])
for slug in extra_client:
    f = os.path.join(pack, "mods", slug + ".pw.toml")
    if os.path.exists(f):
        t = open(f, encoding="utf-8").read()
        if 'side = "both"' in t:
            open(f, "w", encoding="utf-8", newline="\n").write(t.replace('side = "both"', 'side = "client"', 1))
            changed.append(slug)
print(len(changed), "mods pasan a solo-cliente:", ", ".join(sorted(changed)))
