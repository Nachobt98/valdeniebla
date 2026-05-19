# Valdeniebla — UI art pass foundation

## Objetivo de esta PR

Crear una primera base visual versionada para la UI de Valdeniebla sin bloquear la jugabilidad ni depender todavía de arte final.

Esta PR no pretende cerrar la UI definitiva. Pretende dejar preparado el pipeline mínimo para que el juego empiece a moverse hacia la dirección artística definida en `docs/visual_direction.md`.

## Assets añadidos

### Iconos de recursos

Ruta:

```text
assets/ui/icons/resources/
```

Archivos:

- `icon_food.svg`
- `icon_wood.svg`
- `icon_iron.svg`
- `icon_medicine.svg`
- `icon_morale.svg`
- `icon_security.svg`

Uso previsto:

- barra superior;
- panel de gestión;
- tooltips;
- futuras decisiones/eventos con costes.

### Paneles

Ruta:

```text
assets/ui/panels/
```

Archivos:

- `panel_dark_parchment.svg`

Uso previsto:

- panel contextual;
- crónica;
- panel de gestión;
- quest log futuro.

### Botones

Ruta:

```text
assets/ui/buttons/
```

Archivos:

- `button_default.svg`
- `button_important.svg`

Uso previsto:

- botones de navegación;
- botón de avanzar día;
- decisiones importantes.

## Base de rutas

Se añade:

```text
data/ui_asset_database.gd
```

Responsabilidad:

- centralizar rutas de iconos, paneles y botones;
- centralizar colores de estado `activo`, `riesgo`, `bloqueado` y `neutral`;
- evitar rutas hardcodeadas repartidas por escenas o scripts.

## Filosofía visual

Los assets son placeholders serios, no arte final. Buscan:

- paleta apagada;
- lectura clara;
- tono medieval sobrio;
- compatibilidad con UI oscura;
- evitar cartoon brillante;
- evitar ruido excesivo.

## Siguiente integración recomendada

### Paso 1 — Iconos en top bar

Cambiar la barra superior para que los recursos usen icono + número:

```text
[icono comida] 60   [icono madera] 30   [icono hierro] 10 ...
```

### Paso 2 — Iconos en Gestión

Mostrar cada recurso con icono en el panel de Gestión.

### Paso 3 — Estados de oficio con color

En la sección `Oficios activos`, aplicar color:

- `activo`: verde apagado;
- `riesgo`: ámbar/cobre;
- `bloqueado`: rojo oscuro.

### Paso 4 — Paneles con TextureRect / NinePatchRect

Evaluar si Godot renderiza correctamente los SVG como textura de UI. Si no, exportar estos SVG a PNG y usar `NinePatchRect` para paneles y botones.

## Nota técnica

Los SVG son una base editable. Si Godot da problemas de importación, se deben convertir a PNG manteniendo los mismos nombres semánticos y rutas equivalentes.