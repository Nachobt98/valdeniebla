# Infraestructura Godot + IA

Este proyecto usa una estrategia por capas para que un agente de IA pueda trabajar con Godot de forma fiable:

1. Edicion directa del repositorio para scripts, datos y documentacion.
2. MCP baseline basado en Node para lanzar Godot, ejecutar el proyecto y leer salida de depuracion.
3. MCP editor/runtime para inspeccionar y modificar escenas desde Godot cuando el entorno tenga Godot, Python y uv disponibles.
4. Validacion por Git antes de integrar cambios en `main`.

## Estado de esta maquina

Comprobado el 2026-05-19:

- Node.js disponible: `node`.
- npm/npx disponibles como `npm.cmd` y `npx.cmd`.
- El paquete `@coding-solo/godot-mcp` existe en npm.
- No habia Godot instalado en PATH ni localizable en `C:\`.
- Se instalo una copia portable local de Godot 4.6.2 en `.godot-local/`, ignorada por Git.
- El binario local responde a `--version`: `4.6.2.stable.official.71f334935`.
- Se instalo `uv` portable en `.godot-local/uv/`.
- Se clono `slangwald/godot-mcp` en `.godot-local/slangwald-godot-mcp/`.
- Se resolvieron las dependencias Python del servidor MCP con `uv run`.
- El servidor MCP carga correctamente 24 herramientas.
- El editor grafico abre `res://main.tscn` y responde a `get_editor_state`.
- `run_project` arranca la escena principal desde MCP.
- El runtime responde a `get_runtime_tree`.
- El runtime responde a `screenshot`.
- La carga del proyecto en modo headless crashea actualmente con signal 11 antes de devolver validacion util.
- No se encontro `python`, `py`, `uv` ni `winget` en PATH global.

Esto deja preparado y verificado el MCP baseline y el MCP editor/runtime para flujo grafico. La unica limitacion detectada es la validacion headless directa del binario local.

## MCP baseline

El baseline elegido es `Coding-Solo/godot-mcp`, configurado como `godot-baseline` en `.cursor/mcp.json`.

Ventajas:

- No requiere Python.
- Usa Node/npm, ya disponibles en esta maquina.
- Permite lanzar editor, ejecutar proyecto, leer debug output y hacer operaciones basicas de escenas.
- Es una base simple para clientes MCP compatibles como Cursor.

Configuracion:

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx.cmd",
      "args": ["@coding-solo/godot-mcp"],
      "env": {
        "GODOT_PATH": "C:\\Users\\nacho\\Documents\\valdeniebla\\.godot-local\\Godot_v4.6.2-stable_win64_console.exe",
        "GODOT_PATH": "C:\\Users\\nacho\\Documents\\valdeniebla\\.godot-local\\Godot_v4.6.2-stable_win64_console.exe",
        "DEBUG": "true"
      }
    }
  }
}
```

Si se prefiere una instalacion global de Godot, cambiar `GODOT_PATH` por la ruta exacta:

```json
"env": {
  "GODOT_PATH": "C:\\ruta\\a\\Godot_v4.6-stable_win64.exe",
  "DEBUG": "true"
}
```

## MCP editor/runtime

Para la capa potente de trabajo dentro de Godot se integro `slangwald/godot-mcp`.

Motivo:

- Esta orientado a Godot 4.6.
- Expone herramientas de editor: arbol de escena, propiedades, crear/modificar/borrar nodos, senales, abrir/guardar escenas y logs.
- Expone herramientas runtime: screenshot, click e inspeccion del arbol vivo.
- Su arquitectura separa servidor MCP, plugin de editor y autoload de juego.

Componentes versionados en este repo:

- `addons/mcp_bridge/`: plugin de editor.
- `addons/mcp_bridge/LICENSE`: licencia MIT original del plugin vendorizado.
- `mcp_bridge_game.gd`: autoload runtime.
- `mcp_ports.cfg`: puertos del puente.
- `project.godot`: habilita el plugin y el autoload.

Componentes locales ignorados por Git:

- `.godot-local/Godot_v4.6.2-stable_win64_console.exe`.
- `.godot-local/uv/`.
- `.godot-local/slangwald-godot-mcp/`.
- caches y entornos virtuales de `uv`.

Puertos:

- Editor: `9600`.
- Juego en ejecucion: `9601`.

El servidor MCP esta configurado como `godot-editor-runtime` en `.cursor/mcp.json`.

Herramientas que habilita:

- `get_scene_tree`: inspeccionar el arbol de nodos abierto en el editor.
- `get_node_properties`: leer propiedades de cualquier nodo.
- `modify_node`, `create_node`, `delete_node`: modificar escena desde el editor.
- `get_signals`, `connect_signal`: revisar y conectar senales.
- `open_scene`, `save_scene`, `run_project`, `run_scene`, `stop_project`: operar escenas y ejecucion.
- `get_output`: leer logs/errores recientes de Godot.
- `screenshot`, `click`, `get_runtime_tree`: inspeccionar e interactuar con el juego en ejecucion.

## Comandos locales

Diagnostico:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\godot_ai_infra_check.ps1
```

Abrir Godot con este proyecto:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\start_godot_editor.ps1
```

Arrancar manualmente el servidor MCP editor/runtime:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\tools\start_godot_mcp_runtime.ps1
```

En clientes MCP compatibles con `.cursor/mcp.json`, no hace falta arrancar ese ultimo script manualmente: el cliente ejecuta el servidor.

## Flujo de trabajo recomendado

Para cambios normales:

1. Crear rama.
2. Editar scripts/datos desde el repo.
3. Ejecutar validacion Godot por CLI o MCP.
4. Si hay UI o escenas, inspeccionar arbol de escena por MCP.
5. Ejecutar el proyecto y capturar output.
6. Hacer commit solo cuando la validacion sea reproducible.

Para Valdeniebla, las primeras validaciones utiles seran:

- Abrir `main.tscn`.
- Ejecutar escena principal.
- Pulsar `Avanzar dia`.
- Confirmar que se generan eventos de manana y tarde.
- Confirmar que el diario y el panel de recursos se actualizan.
- Revisar errores Godot en output.

## Limitaciones actuales

- El MCP no queda disponible dentro de una sesion ya iniciada del cliente; hay que recargar/reiniciar el cliente MCP para que lea `.cursor/mcp.json`.
- El editor grafico de Godot debe estar abierto para que las herramientas de editor escuchen en `127.0.0.1:9600`.
- El juego debe estar ejecutandose para que `screenshot`, `click` y `get_runtime_tree` funcionen en `127.0.0.1:9601`.
- La validacion headless con el binario local crashea actualmente con signal 11. El flujo principal debe validarse desde el editor grafico hasta aislar ese crash.

## Politica de seguridad

- No autoaprobar herramientas destructivas.
- No tocar `main.tscn` desde MCP sin diff posterior.
- No habilitar plugins en `main` sin una rama dedicada.
- Mantener `addons/` versionado solo cuando el plugin haya sido probado en Godot.
- Evitar instalar dependencias globales sin documentar ruta y version.
