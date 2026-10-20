@echo off
rem Instala (o actualiza) el servidor del pack en Windows. Uso: install-server.bat <URL de pack.toml>
setlocal
set PACK_URL=%1
if "%PACK_URL%"=="" (echo Uso: install-server.bat URL_de_pack.toml & exit /b 1)
set NEOFORGE_VERSION=21.1.262
cd /d "%~dp0"
if not exist "libraries\net\neoforged\neoforge\%NEOFORGE_VERSION%\neoforge-%NEOFORGE_VERSION%-server.jar" (
  curl -fsSL -o neoforge-installer.jar "https://maven.neoforged.net/releases/net/neoforged/neoforge/%NEOFORGE_VERSION%/neoforge-%NEOFORGE_VERSION%-installer.jar"
  java -jar neoforge-installer.jar --installServer
  del neoforge-installer.jar
)
if not exist packwiz-installer-bootstrap.jar curl -fsSL -o packwiz-installer-bootstrap.jar "https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar"
echo %PACK_URL%> pack-url.txt
java -jar packwiz-installer-bootstrap.jar -g -s server "%PACK_URL%"
if not exist eula.txt (echo Acepta el EULA https://aka.ms/MinecraftEULA y crea eula.txt con eula=true)
echo Listo. Arranca con start.bat
