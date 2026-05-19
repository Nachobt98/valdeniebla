# Valdeniebla — Backlog de assets visuales

## Objetivo

Definir el primer paquete visual producible para Valdeniebla. Este backlog está pensado para un **vertical slice visual**, no para arte final completo del juego.

La prioridad es crear identidad, legibilidad y coherencia.

## Prioridades

- **P0 — Necesario para salto visual inmediato.** Debe ir primero.
- **P1 — Muy recomendable para vertical slice.** Entra después de P0.
- **P2 — Ampliación.** Útil, pero no bloquear.
- **P3 — Futuro.** No producir todavía salvo necesidad clara.

## P0 — UI base e identidad inmediata

### 1. Iconos de recursos

Ruta sugerida:

```text
assets/ui/icons/resources/
```

Cantidad: 6 iconos.

| Recurso | Archivo sugerido | Concepto |
|---|---|---|
| Comida | `icon_food.png` | cesta/pan/saco de grano |
| Madera | `icon_wood.png` | troncos/haz de leña |
| Hierro | `icon_iron.png` | lingote/herramienta |
| Medicina | `icon_medicine.png` | hierbas/vial/venda |
| Moral | `icon_morale.png` | vela/copa/manos reunidas |
| Seguridad | `icon_security.png` | escudo/valla/lanza |

Formato recomendado:

- PNG transparente.
- 64x64 fuente maestra.
- Legible a 24x24 y 32x32.
- Estilo pintado/ilustrado simple.
- Sin bordes negros gruesos tipo cartoon.

### 2. Paneles UI base

Ruta sugerida:

```text
assets/ui/panels/
```

Assets:

| Archivo | Uso |
|---|---|
| `panel_dark_parchment.png` | panel contextual principal |
| `panel_top_bar.png` | barra superior |
| `panel_bottom_bar.png` | barra inferior de acciones |
| `panel_tooltip.png` | tooltips y pequeñas ayudas |
| `panel_alert.png` | decisiones/eventos importantes |

Formato recomendado:

- PNG 9-slice si Godot lo aprovecha.
- Bordes sobrios, textura sutil.
- Fondo oscuro cálido o pergamino envejecido oscuro.
- No debe competir con el texto.

### 3. Botones UI

Ruta sugerida:

```text
assets/ui/buttons/
```

Assets:

| Archivo | Uso |
|---|---|
| `button_default.png` | estado normal |
| `button_hover.png` | hover |
| `button_pressed.png` | pulsado |
| `button_disabled.png` | desactivado |
| `button_important.png` | avanzar día/decisión importante |

Formato:

- PNG 9-slice.
- Mismo lenguaje que paneles.
- Estado hover claro pero no chillón.

### 4. Separadores y ornamentos

Ruta sugerida:

```text
assets/ui/ornaments/
```

Assets:

| Archivo | Uso |
|---|---|
| `divider_thin.png` | separar secciones |
| `divider_ornate.png` | títulos importantes |
| `corner_metal.png` | esquina decorativa sobria |
| `status_active_marker.png` | activo |
| `status_risk_marker.png` | riesgo |
| `status_blocked_marker.png` | bloqueado |

## P0 — Retratos protagonistas

Ruta sugerida:

```text
assets/characters/portraits/main/
```

Formato recomendado:

- PNG.
- Tamaño maestro: 1024x1024 o 768x768.
- Export runtime: 256x256 o 384x384.
- Fondo atmosférico simple.
- Mismo encuadre para todos.
- Busto/medio cuerpo.

| Personaje | Archivo | Prompt visual resumido |
|---|---|---|
| Aldric | `portrait_aldric.png` | aprendiz de herrero joven, hollín, cuero, mirada desafiante |
| Gareth | `portrait_gareth.png` | herrero veterano, corpulento, barba/rostro duro, delantal gastado |
| Mara | `portrait_mara.png` | tabernera cálida y astuta, mirada observadora, tonos cálidos |
| Elowen | `portrait_elowen.png` | curandera reservada, hierbas, vendas, calma cansada |
| Oren | `portrait_oren.png` | alcalde preocupado, ropa algo mejor pero gastada, responsabilidad |
| Tomas | `portrait_tomas.png` | monje/escriba, pluma/cuaderno, melancolía serena |
| Bran | `portrait_bran.png` | granjero robusto, barro, manos fuertes, cansancio digno |
| Lysa | `portrait_lysa.png` | pastora vigilante, capa corta, bastón/honda, tonos verdes/grises |

Criterio:

- El jugador debe reconocer el oficio antes de leer el texto.
- Deben sentirse parte del mismo mundo.
- No deben parecer una party épica genérica.

## P1 — Edificios principales

Ruta sugerida:

```text
assets/environment/buildings/
```

Formato recomendado:

- PNG transparente.
- Vista top-down/2.5D coherente con el mapa actual.
- Tamaño variable según edificio, pero con escala común.
- Sombra suave incluida o generada por shader/engine, decidir una sola vía.

| Edificio | Archivo | Rasgos visuales |
|---|---|---|
| Herrería | `building_forge.png` | humo, yunque, techo oscuro, brasas cálidas |
| Taberna | `building_tavern.png` | luz cálida, cartel, barriles, vida social |
| Capilla | `building_chapel.png` | sobria, piedra/madera, campana pequeña |
| Casa comunal | `building_communal_house.png` | centro administrativo, mayor tamaño |
| Casa de curas | `building_healers_house.png` | hierbas, telas, luz suave |
| Granjas | `building_farms.png` | campos, sacos, tierra cultivada |
| Prados | `building_pastures.png` | cercas, ganado sugerido, hierba irregular |
| Almacén | `building_storehouse.png` | sacos, cajas, techo robusto |
| Pozo | `building_well.png` | piedra, cubo, punto central utilitario |

## P1 — Sprites de mundo protagonistas

Ruta sugerida:

```text
assets/characters/world_sprites/main/
```

Primera entrega mínima:

- 1 sprite idle por protagonista.
- 1 variante caminando si el pipeline lo permite.
- Silueta y color diferenciables.

Formato recomendado:

- PNG spritesheet o PNG individual.
- Tamaño base a decidir según mapa actual.
- Prioridad: legibilidad, no animación compleja.

| Personaje | Archivo sugerido |
|---|---|
| Aldric | `sprite_aldric_idle.png` |
| Gareth | `sprite_gareth_idle.png` |
| Mara | `sprite_mara_idle.png` |
| Elowen | `sprite_elowen_idle.png` |
| Oren | `sprite_oren_idle.png` |
| Tomas | `sprite_tomas_idle.png` |
| Bran | `sprite_bran_idle.png` |
| Lysa | `sprite_lysa_idle.png` |

## P1 — Atmósfera de mapa

Ruta sugerida:

```text
assets/environment/effects/
```

Assets:

| Archivo | Uso |
|---|---|
| `fog_overlay_soft.png` | capa de niebla sutil |
| `vignette_soft.png` | viñeteado discreto |
| `smoke_puff_01.png` | humo de herrería/chimeneas |
| `warm_window_glow.png` | luz cálida de ventanas |
| `cold_shadow_patch.png` | sombra fría para bosque/bordes |

Criterio:

- La niebla debe sugerir, no tapar.
- La atmósfera debe aumentar identidad sin perjudicar lectura.

## P1 — Props básicos

Ruta sugerida:

```text
assets/environment/props/
```

Assets:

- `prop_barrel.png`
- `prop_crate.png`
- `prop_sack.png`
- `prop_firewood_stack.png`
- `prop_cart.png`
- `prop_fence_short.png`
- `prop_fence_broken.png`
- `prop_anvil.png`
- `prop_hay_bale.png`
- `prop_herb_rack.png`
- `prop_signpost.png`

## P2 — Fondos / pantallas especiales

Ruta sugerida:

```text
assets/backgrounds/
```

Assets:

| Archivo | Uso |
|---|---|
| `bg_village_morning.png` | fondo atmosférico general |
| `bg_village_evening.png` | variante cálida/tensa |
| `bg_tavern_interior.png` | eventos de Mara/taberna |
| `bg_forge_interior.png` | eventos de Aldric/Gareth |
| `bg_chapel_interior.png` | eventos de Tomas |
| `bg_forest_edge.png` | amenazas y niebla |
| `bg_northern_road.png` | expediciones futuras |

No producir todos de golpe. Elegir 1-2 para vertical slice.

## P2 — Estados y alertas visuales

Ruta sugerida:

```text
assets/ui/status/
```

Assets:

- `badge_active.png`
- `badge_risk.png`
- `badge_blocked.png`
- `badge_injured.png`
- `badge_stressed.png`
- `badge_quest.png`
- `badge_decision.png`
- `badge_threat.png`

## P3 — Futuro

No producir todavía salvo necesidad muy clara:

- Animaciones de combate.
- Retratos de 8-12 secundarios.
- Variantes estacionales completas.
- Variantes dañadas/mejoradas de todos los edificios.
- Cinemáticas.
- VFX avanzados de niebla.
- Grandes ilustraciones de capítulo.

## Orden recomendado de producción

### Lote 1 — UI mínima profesional

1. Iconos de recursos.
2. Paneles base.
3. Botones.
4. Separadores.
5. Estados activo/riesgo/bloqueado.

Resultado esperado: el juego parece más profesional aunque el mapa siga parcial.

### Lote 2 — Rostros de la aldea

1. Retratos de los 8 protagonistas.
2. Integración en panel de habitante.
3. Integración futura en eventos/quests.

Resultado esperado: el jugador asocia sistemas con personas.

### Lote 3 — Aldea visible

1. Edificios principales.
2. Props básicos.
3. Niebla/atmósfera.
4. Sprites simples de protagonistas.

Resultado esperado: la aldea deja de parecer un diagrama y empieza a parecer lugar.

### Lote 4 — Fondos narrativos

1. Interior de taberna.
2. Interior de herrería.
3. Borde del bosque/camino norte.

Resultado esperado: eventos y quests ganan presencia visual.

## Checklist para aceptar un asset

Antes de integrar un asset, comprobar:

- ¿Encaja con la paleta?
- ¿Se lee bien en tamaño real dentro del juego?
- ¿Tiene el mismo nivel de detalle que el resto?
- ¿Refuerza oficio/personaje/lugar?
- ¿No sobrecarga el texto?
- ¿Tiene nombre y carpeta correctos?
- ¿Puede reutilizarse en varias pantallas?

## Prompts base para generar assets

### Retrato protagonista

```text
2D stylized semi-painted portrait of [character], medieval frontier village inhabitant, grounded realistic clothing, subtle worn textures, atmospheric misty background, warm side light and cool ambient shadows, melancholic but human expression, not heroic fantasy armor, not cartoon, consistent muted palette, bust portrait, high readability, painterly but clean, game character portrait
```

### Edificio

```text
2D stylized medieval village building asset, [building type], top-down / slight isometric view, worn wood and stone, muted mossy palette, subtle warm lights, transparent background, readable silhouette, cohesive with atmospheric medieval settlement game, not cartoon, not high fantasy, no text
```

### Icono recurso

```text
small 2D painted game UI icon of [resource], medieval rustic style, transparent background, muted colors, readable at 24x24, soft edges, subtle parchment-compatible shading, no text, no cartoon outline
```

### Panel UI

```text
dark medieval parchment UI panel, subtle worn texture, old wood and tarnished brass border, elegant but readable, 9-slice friendly, no text, no symbols, transparent background edges if possible, muted warm brown and charcoal palette
```

## Nota final

El arte debe servir al sistema. Si un asset no ayuda a entender mejor la aldea, sus habitantes, sus decisiones o su misterio, puede esperar.