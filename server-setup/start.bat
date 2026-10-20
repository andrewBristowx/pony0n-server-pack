@echo off
cd /d "%~dp0"
if "%MEM%"=="" set MEM=8G
if not "%AUTO_UPDATE%"=="0" if exist pack-url.txt if exist packwiz-installer-bootstrap.jar (
  set /p PACK_URL=<pack-url.txt
  java -jar packwiz-installer-bootstrap.jar -g -s server %PACK_URL%
)
java -Xms%MEM% -Xmx%MEM% -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 @user_jvm_args.txt @libraries/net/neoforged/neoforge/21.1.262/win_args.txt nogui %*
