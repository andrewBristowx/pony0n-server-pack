#!/usr/bin/env bash
# Instala (o actualiza) el servidor del pack. Uso:  ./install-server.sh <URL de pack.toml>
# Requiere: Java 21 y curl. Se puede ejecutar de nuevo en cualquier momento para ACTUALIZAR el servidor con los cambios del pack.
set -euo pipefail
PACK_URL="${1:?Uso: $0 <URL de pack.toml>   (p. ej. https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml)}"
NEOFORGE_VERSION="21.1.262"   # debe coincidir con [versions] neoforge de pack.toml
cd "$(dirname "$0")"

if ! command -v java >/dev/null; then echo "Falta Java 21 (https://adoptium.net)"; exit 1; fi

# 1) NeoForge (solo la primera vez)
if [ ! -f "libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/neoforge-$NEOFORGE_VERSION-server.jar" ]; then
  echo ">> Instalando NeoForge $NEOFORGE_VERSION..."
  curl -fsSL -o neoforge-installer.jar "https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE_VERSION/neoforge-$NEOFORGE_VERSION-installer.jar"
  java -jar neoforge-installer.jar --installServer
  rm -f neoforge-installer.jar
fi

# 2) packwiz-installer (descarga/actualiza los mods y configuraciones del pack, solo el lado servidor)
if [ ! -f packwiz-installer-bootstrap.jar ]; then
  curl -fsSL -o packwiz-installer-bootstrap.jar "https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar"
fi
echo "$PACK_URL" > pack-url.txt
echo ">> Sincronizando mods y configuración desde $PACK_URL ..."
java -jar packwiz-installer-bootstrap.jar -g -s server "$PACK_URL"

# 3) Primer arranque: EULA y propiedades recomendadas
if [ ! -f eula.txt ]; then
  echo "Para arrancar debes aceptar el EULA de Minecraft: https://aka.ms/MinecraftEULA"
  read -r -p "¿Aceptas? (si/no) " a
  [ "$a" = "si" ] && echo "eula=true" > eula.txt || { echo "Sin EULA no se puede arrancar."; exit 1; }
fi
if [ ! -f server.properties ]; then cp "$(dirname "$0")/server.properties.example" server.properties 2>/dev/null || true; fi
echo ">> Listo. Arranca con ./start.sh"
