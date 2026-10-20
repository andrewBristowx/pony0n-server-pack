#!/usr/bin/env bash
# Arranca el servidor con banderas de JVM recomendadas (G1, pausas cortas). Ajusta MEM según tu máquina (8G recomendado para este pack).
cd "$(dirname "$0")"
MEM="${MEM:-8G}"

# Actualización automática: antes de arrancar se sincronizan mods y configuración con el pack (los cambios que se suban al
# repositorio llegan al servidor en el siguiente reinicio). Desactívala con AUTO_UPDATE=0 ./start.sh
if [ "${AUTO_UPDATE:-1}" = "1" ] && [ -f pack-url.txt ] && [ -f packwiz-installer-bootstrap.jar ]; then
  echo ">> Buscando actualizaciones del pack..."
  java -jar packwiz-installer-bootstrap.jar -g -s server "$(cat pack-url.txt)" || echo "!! No se pudo actualizar; se arranca con lo que hay."
fi
exec java -Xms"$MEM" -Xmx"$MEM" \
  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \
  -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
  @user_jvm_args.txt @libraries/net/neoforged/neoforge/21.1.262/unix_args.txt nogui "$@"
