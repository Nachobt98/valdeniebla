# Valdeniebla — Dirección de diseño

## Definición

Valdeniebla es un simulador narrativo de asentamiento medieval con gestión de aldea, colonia viva y elementos RPG. El jugador no controla a un héroe aislado: guía una comunidad que produce, se relaciona, recuerda y paga consecuencias.

## Pilares

1. **Gestión de aldea**: recursos, edificios, prioridades, oficios, producción diaria, seguridad, moral y crecimiento.
2. **Colonia viva**: NPCs con estados, rutinas, relaciones, ubicación, trabajo y eventos emergentes.
3. **RPG narrativo**: protagonistas con defectos, vínculos, quests personales, decisiones cruzadas y memoria.
4. **Amenaza subordinada a la aldea**: expediciones, defensa, heridas y riesgos que afectan producción y relaciones.

## Qué es

- Un RPG de aldea viva donde el asentamiento es el centro emocional y sistémico.
- Un colony sim narrativo con NPCs concretos, no solo números.
- Un juego de gestión donde el crecimiento visual de la aldea importa.
- Un drama de comunidad: oficios, secretos, lealtades, cansancio, heridas y memoria.

## Qué no es

- No es un RPG clásico de party con rotación de combate.
- No es un city-builder abstracto donde los habitantes son solo población.
- No es una visual novel lineal.
- No es un juego de combate como eje principal.
- No es un imperio desde el minuto uno.

## Regla de oro

Cada sistema debe responder al menos a una pregunta:

- ¿Ayuda a gestionar la aldea?
- ¿Hace que parezca viva?
- ¿Profundiza en personajes concretos?
- ¿Crea consecuencias interesantes?

Si un sistema solo cambia números y no cambia la lectura de la aldea, no está terminado.

## Capas de habitantes

### Protagonistas

Cantidad inicial: 8.

Tienen ficha completa, relaciones, estados, papel productivo, eventos propios y futuras quests personales.

### Secundarios

Cantidad objetivo inicial: 8–12.

Deben tener nombre, oficio, ubicación, estado simple y eventos menores. No necesitan arco largo obligatorio, pero algunos pueden ascender si la simulación lo justifica.

### Población común

Cantidad objetivo: 20–40+ representada de forma agregada.

Aporta escala, consumo, presión social, producción abstracta y vida visual. No requiere ficha individual completa.

## Reparto protagonista base

- **Aldric**: aprendiz de herrero. Ambición, orgullo y necesidad de demostrar valía.
- **Gareth**: herrero veterano. Tradición, autoridad y miedo a perder control.
- **Mara**: tabernera. Rumores, vínculos sociales y lectura emocional de la aldea.
- **Elowen**: curandera. Salud, culpa, secretos y dilemas éticos.
- **Oren**: alcalde. Gestión política, legitimidad y miedo al fallo.
- **Tomas**: monje/escriba. Crónica, memoria, fe y verdad incómoda.
- **Bran**: granjero. Subsistencia material, cansancio y supervivencia.
- **Lysa**: pastora. Frontera rural, pragmatismo, defensa y exploración inicial.

## Roadmap operativo

### F0 — Fundación

UI medieval, NPCs, eventos, crónica, estado de aldea y separación básica de datos/sistemas.

Estado actual: completada.

### F1 — Gestión mínima

Recursos, prioridades, edificios, oficios y producción diaria.

Estado actual: avanzada. Falta consolidar producción ligada a NPCs y oficios.

### F2 — Aldea visual

Mapa simple, edificios clicables y NPCs visibles con movimiento básico.

Estado actual: iniciada con mapa data-driven y `VillageMapView`.

### F3 — Quests RPG

Primer arco Aldric/Gareth, una quest cruzada y primer misterio local.

Estado actual: pendiente.

### F4 — Amenazas

Primera expedición/amenaza abstracta, heridas, riesgo y consecuencias productivas.

Estado actual: pendiente.

### F5 — Vertical slice

Primer mes jugable: mercado, crisis, quest y amenaza con cierre de capítulo.

Estado actual: pendiente.

## Prioridades inmediatas

1. Consolidar mapa visual data-driven.
2. Separar producción diaria en un sistema propio.
3. Hacer que los oficios de los protagonistas sostengan edificios y recursos.
4. Convertir el panel de Quests en un sistema real.
5. Añadir una primera amenaza abstracta del camino norte o del bosque.

## Criterio de calidad

Un sistema no se considera hecho si solo existe en código o modifica una cifra aislada. Debe afectar a lo que el jugador ve, lee, decide o recuerda.