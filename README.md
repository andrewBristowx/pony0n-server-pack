# Pony0n Server — modpack (NeoForge 1.21.1) con SomitaMultiverCore

Modpack **actualizable** para Prism Launcher y servidor, montado con [packwiz](https://packwiz.infra.link/): el repositorio solo guarda
metadatos (de dónde baja cada mod, su hash y de qué lado va); los `.jar` se descargan al instalar. Cliente y servidor salen de la
**misma fuente**: cualquier cambio que se suba aquí llega a los jugadores al abrir el juego y al servidor en su siguiente reinicio.

- Base: el modpack *Pony0n's Server* (exportación de CurseForge de ArrivedBog593), convertido a packwiz: **216 mods resueltos en Modrinth**,
  37 desde el CDN de CurseForge y 3 archivos propios en `localmods/`.
- Minecraft **1.21.1**, NeoForge **21.1.262** (el mínimo que exigen varios mods del pack; el manifiesto original decía 21.1.235).
- Se añade **SomitaMultiverCore** (solo servidor) y **spark** (perfilador, ambos lados).
- Optimización del servidor que ya trae el pack: ModernFix, FerriteCore, Lithium, C2ME, Noisium, Alternate Current, ServerCore, Saturn,
  Clumps, AllTheLeaks, Immersive Optimization. Cliente: Sodium (+Extra/Options), Iris, ImmediatelyFast, Entity Culling, MoreCulling, Dynamic FPS.

> `https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml` en este documento es la dirección **raw** de `pack.toml` de tu repositorio, por ejemplo
> `https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml` (el repositorio debe ser público para que Prism y el servidor puedan leerla).

## Jugadores (Prism Launcher)

1. Crea una instancia **Minecraft 1.21.1 + NeoForge 21.1.262** (Java 21; 6-8 GB de RAM recomendados).
2. Descarga [`packwiz-installer-bootstrap.jar`](https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest) y ponlo en la carpeta
   `minecraft` de la instancia (*clic derecho en la instancia → Carpeta de la instancia → minecraft*).
3. *Editar instancia → Ajustes → Comandos personalizados → Comando previo al lanzamiento*:
   ```
   "$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main/pack.toml
   ```
4. Juega. En cada arranque se sincronizan mods, configuración y shaders con el pack (la primera vez tarda unos minutos).

Notas: `options.txt` y los shaders se instalan una vez; tus cambios de opciones se respetan. Los mods marcados solo-cliente
(mapas, shaders, menús, rendimiento de render) no se instalan en el servidor.

## Servidor

Requisitos: **Java 21**, `curl`, 8 GB de RAM libres para el servidor y ~15 GB de disco.

```bash
mkdir mi-servidor && cd mi-servidor
# copia aquí el contenido de la carpeta server-setup/ de este repositorio (start.sh, start.bat, server.properties.example)
./start.sh          # TODO en uno: instala NeoForge, descarga mods y configuración, pide el EULA y arranca
```

Windows: `start.bat`. Opciones: `MEM=10G ./start.sh` (memoria), `EULA=true ./start.sh` (aceptar el EULA sin preguntar),
`AUTO_UPDATE=0 ./start.sh` (arrancar sin actualizar), `INSTALL_ONLY=1 ./start.sh` (instalar y salir).

**Actualización automática**: cada vez que ejecutas `start.sh` se sincroniza antes con el pack, así que basta con reiniciar el
servidor para recibir los cambios que subamos al repositorio. La primera vez tarda unos minutos (descarga ~1 GB).

Propiedades recomendadas en `server.properties.example` (`allow-flight=true` es necesario por Create/Sable; `online-mode=true` para que los
jugadores vean su skin en el NPC).

> Los clientes de vanilla puros **no pueden entrar**: el pack necesita el cliente con los mismos mods (es lo normal en un modpack).

## Cómo queda el servidor (SomitaMultiverCore)

Al primer arranque se aplica `config/somitamultivercore/bootstrap.json` (una sola vez por paso; si lo cambias después usa `/mv bootstrap redo <paso>`):

| Mundo | Qué es |
|---|---|
| `spawn` (lobby) | Tu estructura `spawn.nbt` pegada en un mundo vacío. **Protegido**: no se rompen ni colocan bloques, pero se puede interactuar con todo (puertas, cofres, palancas, máquinas, mobs). Borde del mundo ajustado a la losa (104×104) para que nadie camine fuera de ella y red de seguridad contra el vacío. Siempre es donde apareces al conectarte. |
| `survival`, `survival_nether`, `survival_the_end` | Reino **survival**: sus tres dimensiones conectadas con portales de ida y vuelta, borde común de **10 000** bloques. Permanente. |
| `recursos`, `recursos_nether`, `recursos_the_end` | Reino **recursos**: igual que survival (borde común de 10 000) pero **se reinicia cada semana** (lunes 04:00, hora de Ciudad de México): nuevas semillas para todas sus dimensiones. El lobby y survival no se tocan. Avisos en el chat a los 10, 5 y 1 minutos; quien esté dentro termina en el lobby. |

El **NPC** del spawn (jugador falso *SomitaNPC*) lo ve cada jugador **con su propia skin**; al hacer clic derecho se abre un menú para elegir Survival o Recursos.

### Comandos útiles (operadores)

```text
/mv list | /mv info <mundo> | /mv lobby            # /mv lobby lo puede usar cualquiera
/mv npc create <id> [menú]                          # crea un NPC espejo donde estás parado
/mv npc menu add <menú> <casilla> <objeto> <mundo> <nombre>   # añade una opción al menú
/mv npc title <id> <texto>                          # texto flotante (admite &6 colores)
/mv realm info recursos                             # mundos, borde y reinicio de un reino
/mv realm schedule recursos weekly monday 04:00 America/Mexico_City
/mv realm schedule recursos off                     # quita el reinicio semanal
/mv realm regen recursos [semilla]                  # reiniciar AHORA (pide /mv confirm; el terreno viejo va a la papelera)
/mv realm border survival 10000                     # cambiar el borde común
/mv modify set build true spawn                     # permitir construir en el spawn (los operadores ya pueden siempre)
/mv gamerule set keepInventory true recursos        # reglas de juego distintas por mundo
/mv bootstrap status                                # qué pasos de bootstrap.json se aplicaron
```

El terreno anterior de un reinicio se guarda en `somita-backups/trash/` (recuperable). Todo queda en `logs/somitamultivercore-audit.log`.

## Mantenimiento del pack

```bash
packwiz modrinth add <slug>        # añadir un mod (o: packwiz curseforge add <slug>)
packwiz update --all               # actualizar todos los mods
packwiz refresh                    # recalcular el índice (siempre antes de subir)
git add -A && git commit -m "..." && git push
```

- Marca un mod como solo-cliente editando `side = "client"` en su `mods/*.pw.toml` (o `server` para solo-servidor).
- **SomitaMultiverCore** vive en `localmods/` (se descarga por URL desde este repositorio). Para actualizarlo: copia el nuevo `.jar` a
  `localmods/`, ejecuta `python3 tools/finalize_pack.py . https://raw.githubusercontent.com/andrewBristowx/pony0n-server-pack/main` (regenera su `.pw.toml` con el hash nuevo y refresca el índice) y sube.
- Los 3 archivos de `localmods/` no existen en ningún sitio público: `bendy-lib-forge-5.1.jar`, `VanillaBackport-…-patched.jar`
  (una versión parcheada del mod) y SomitaMultiverCore.
- **No añadas Chunky**: choca con Distant Horizons (excepción en cada carga de chunk en el servidor).
- Los `.gitattributes` fuerzan finales de línea LF: con CRLF el hash de `index.toml` no coincide y el instalador falla.
