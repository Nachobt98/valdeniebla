# Valdeniebla

Valdeniebla es un prototipo de simulador narrativo medieval desarrollado en Godot 4.

La intención del proyecto es construir una aldea viva donde los personajes tengan rasgos, relaciones, estados internos y memoria narrativa. El jugador observa e influye en la evolución de la comunidad a través del paso de los días, los eventos emergentes y las decisiones futuras de gestión.

## Estado actual

La rama `feature-village-core` introduce la primera base de la versión 0.2 del prototipo.

Incluye:

- 8 habitantes iniciales.
- Selector de NPCs.
- Relaciones bidireccionales entre personajes.
- Estados internos: salud, ánimo y estrés.
- Habilidades básicas por personaje.
- Eventos con varios actores.
- Condiciones simples para eventos.
- Efectos sobre stats, estados y relaciones.
- Crónica global de la aldea.
- Vista central con resumen del estado de Valdeniebla.

## Bucle jugable actual

1. El jugador consulta los habitantes de la aldea.
2. Selecciona un NPC para ver sus rasgos, habilidades, estado y relaciones.
3. Pulsa `Avanzar día`.
4. El sistema genera eventos de mañana y tarde.
5. Los eventos modifican el estado de los personajes.
6. La crónica registra lo ocurrido y sus consecuencias.

## Objetivo de diseño

El objetivo no es construir todavía un RPG tradicional ni un city-builder completo. La prioridad es validar el núcleo narrativo:

> Personajes + relaciones + eventos + consecuencias + diario = historia emergente.

## Próximos pasos recomendados

- Separar datos de NPCs y eventos en archivos propios.
- Añadir recursos básicos de aldea: comida, madera, hierro, moral y seguridad.
- Añadir decisiones semanales del jugador.
- Añadir eventos únicos y eventos encadenados.
- Añadir guardado/carga.
- Mejorar presentación visual con tema propio.

## Requisitos

- Godot 4.x

## Ejecución

Abre el proyecto desde Godot y ejecuta la escena principal configurada en `project.godot`.
