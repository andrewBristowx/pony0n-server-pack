@echo off
rem Instala (la primera vez), actualiza y arranca el servidor del pack en Windows.  Uso: start.bat
rem   set MEM=10G           memoria (por defecto 8G)      set AUTO_UPDATE=0   arrancar sin actualizar
rem   set EULA=true         acepta el EULA (https://aka.ms/MinecraftEULA)
setlocal
cd /d "%~dp0"
if "%PACK_URL%"=="" set PACK_URL=https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml
set NEOFORGE_VERSION=21.1.262
if "%MEM%"=="" set MEM=8G

where java >nul 2>nul || (echo Falta Java 21: https://adoptium.net & exit /b 1)
where curl >nul 2>nul || (echo Falta curl & exit /b 1)

if not exist "libraries\net\neoforged\neoforge\%NEOFORGE_VERSION%\win_args.txt" (
  echo Instalando NeoForge %NEOFORGE_VERSION% ...
  curl -fsSL -o neoforge-installer.jar "https://maven.neoforged.net/releases/net/neoforged/neoforge/%NEOFORGE_VERSION%/neoforge-%NEOFORGE_VERSION%-installer.jar" || exit /b 1
  java -jar neoforge-installer.jar --installServer || exit /b 1
  del neoforge-installer.jar
)
if not exist packwiz-installer-bootstrap.jar curl -fsSL -o packwiz-installer-bootstrap.jar "https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar"
set DO_UPDATE=1
if "%AUTO_UPDATE%"=="0" set DO_UPDATE=0
if not exist mods set DO_UPDATE=1
if "%DO_UPDATE%"=="1" (
  echo Sincronizando mods y configuracion con el pack...
  java -jar packwiz-installer-bootstrap.jar -g -s server "%PACK_URL%" || (if not exist mods (echo La instalacion del pack fallo & exit /b 1))
)
if not exist server.properties if exist server.properties.example copy server.properties.example server.properties >nul
findstr /b "eula=true" eula.txt >nul 2>nul || (
  if "%EULA%"=="true" (echo eula=true> eula.txt) else (
    echo Debes aceptar el EULA de Minecraft: https://aka.ms/MinecraftEULA
    set /p A=Aceptas? ^(si/no^) 
    if /i not "%A%"=="si" exit /b 1
    echo eula=true> eula.txt
  )
)
echo Arrancando con %MEM% de memoria...
java -Xms%MEM% -Xmx%MEM% -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 @libraries/net/neoforged/neoforge/%NEOFORGE_VERSION%/win_args.txt nogui %*
