#!/usr/bin/env bash
# Instala (la primera vez), actualiza y arranca el servidor del pack. Un solo comando:   ./start.sh
#
#   MEM=10G ./start.sh        memoria del servidor (por defecto 8G)
#   AUTO_UPDATE=0 ./start.sh  arrancar sin buscar actualizaciones del pack
#   INSTALL_ONLY=1 ./start.sh instalar/actualizar y salir sin arrancar
#   BOOTSTRAP_ARGS=--bootstrap-no-update ./start.sh   no consultar la API de GitHub (necesita packwiz-installer.jar en la carpeta)
#   EULA=true ./start.sh      aceptar el EULA de Minecraft sin preguntar (https://aka.ms/MinecraftEULA)
#
# Requisitos: Java 21 y curl. Copia esta carpeta (server-setup) donde quieras que viva el servidor.
set -euo pipefail
cd "$(dirname "$0")"

PACK_URL="${PACK_URL:-https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml}"
NEOFORGE_VERSION="21.1.262"   # debe coincidir con [versions] neoforge de pack.toml
MEM="${MEM:-8G}"

command -v java >/dev/null || { echo "!! Falta Java 21 (https://adoptium.net)"; exit 1; }
command -v curl >/dev/null || { echo "!! Falta curl"; exit 1; }
JV="$(java -version 2>&1 | grep -m1 ' version "' | sed -E 's/.* version "([0-9]+).*/\1/')"
[ "${JV:-0}" -ge 21 ] || { echo "!! Se necesita Java 21 o superior (tienes Java $JV)"; exit 1; }

# 1) NeoForge (solo si falta)
if [ ! -f "libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/unix_args.txt" ]; then
  echo ">> Instalando NeoForge $NEOFORGE_VERSION (primera vez)..."
  curl -fsSL -o neoforge-installer.jar "https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE_VERSION/neoforge-$NEOFORGE_VERSION-installer.jar"
  java -jar neoforge-installer.jar --installServer
  rm -f neoforge-installer.jar neoforge-installer.jar.log
fi

# 2) packwiz-installer: descarga y mantiene al día los mods y configuraciones del pack (solo el lado servidor)
if [ ! -f packwiz-installer-bootstrap.jar ]; then
  curl -fsSL -o packwiz-installer-bootstrap.jar "https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar"
fi
if [ ! -d mods ] || [ "${AUTO_UPDATE:-1}" = "1" ]; then
  echo ">> Sincronizando mods y configuración con el pack ($PACK_URL)..."
  if ! java -jar packwiz-installer-bootstrap.jar ${BOOTSTRAP_ARGS:-} -g -s server "$PACK_URL"; then
    [ -d mods ] && echo "!! No se pudo actualizar; se continúa con lo que hay." || { echo "!! La instalación del pack falló."; exit 1; }
  fi
fi

# 3) Propiedades recomendadas (solo si no existen)
[ -f server.properties ] || cp server.properties.example server.properties 2>/dev/null || true

# 4) EULA
if ! grep -qs '^eula=true' eula.txt 2>/dev/null; then
  if [ "${EULA:-}" = "true" ]; then
    echo "eula=true" > eula.txt
  elif [ -t 0 ]; then
    echo "Para arrancar debes aceptar el EULA de Minecraft: https://aka.ms/MinecraftEULA"
    read -r -p "¿Aceptas? (si/no) " a
    [ "$a" = "si" ] || { echo "Sin EULA no se puede arrancar."; exit 1; }
    echo "eula=true" > eula.txt
  else
    echo "!! Acepta el EULA (https://aka.ms/MinecraftEULA) y arranca con:  EULA=true ./start.sh"; exit 1
  fi
fi

if [ "${INSTALL_ONLY:-0}" = "1" ]; then echo ">> Instalación lista."; exit 0; fi

# 5) Arranque con banderas de JVM recomendadas (G1, pausas cortas)
echo ">> Arrancando con $MEM de memoria..."
exec java -Xms"$MEM" -Xmx"$MEM" \
  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \
  -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
  @libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/unix_args.txt nogui "$@"
