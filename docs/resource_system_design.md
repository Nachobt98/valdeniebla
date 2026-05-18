# Sistema de recursos de Valdeniebla

## Objetivo

El sistema de recursos debe convertir Valdeniebla en una aldea gestionable, no en una lista de eventos. Cada recurso debe crear decisiones, consecuencias y conexiones entre edificios, habitantes, eventos, quests y crecimiento visual.

Esta primera versión busca una economía mínima, clara y extensible. No pretende simular todos los detalles de una ciudad medieval, sino crear una base jugable sobre la que añadir prioridades, construcción, quests, amenazas y combate.

---

## Principios de diseño

1. **Pocos recursos, usos claros.** Si un recurso no genera decisiones, no entra todavía.
2. **La aldea consume aunque el jugador no actúe.** El tiempo debe tener peso.
3. **Los edificios no son decoración.** Cada lugar del mapa debe tener función sistémica.
4. **Los NPCs importan.** Los protagonistas modifican producción, riesgos o narrativa.
5. **La narrativa afecta a la economía.** Los eventos pueden sumar o restar recursos.
6. **La economía afecta a la narrativa.** Escasez, abundancia o inseguridad deben condicionar eventos y quests futuras.

---

## Recursos iniciales

La primera versión usa seis recursos:

| Recurso | Tipo | Función principal |
|---|---|---|
| Comida | Material | Supervivencia diaria de la población |
| Madera | Material | Construcción, reparaciones y crecimiento |
| Hierro | Material | Herramientas, herrería, defensa y mejoras técnicas |
| Medicina | Material | Curación, enfermedades, heridas y crisis sanitarias |
| Moral | Social | Estabilidad emocional y cohesión de la aldea |
| Seguridad | Social/estratégico | Defensa, riesgo exterior y protección de recursos |

---

## Comida

La comida es el recurso de supervivencia.

### Se genera con

- Granjas.
- Prados.
- Eventos de cosecha.
- Comercio futuro.
- Caza o expediciones futuras.

### Se consume por

- Habitantes cada día.
- Viajeros acogidos.
- Celebraciones.
- Expediciones.
- Crisis, invierno o eventos negativos futuros.

### Uso jugable

- Mantener viva a la población.
- Aceptar nuevos habitantes.
- Organizar festivales.
- Alimentar expediciones.
- Resolver eventos de hambre, enfermedad o refugio.

### Crisis

Si la comida baja demasiado:

- Baja la moral.
- Sube el estrés.
- Baja la salud media.
- Aumentan eventos de conflicto.
- En futuras versiones, habitantes pueden marcharse o morir.

---

## Madera

La madera es el recurso de construcción básica.

### Se genera con

- Tala futura.
- Eventos de recolección.
- Comercio.
- Prados/bosque cuando exista mapa ampliado.

### Se consume por

- Edificios nuevos.
- Reparaciones.
- Mejoras de viviendas.
- Empalizadas y defensas.
- Calefacción/invierno futuro.

### Uso jugable

- Crecimiento visual de la aldea.
- Reparar daños tras tormentas o ataques.
- Construir edificios productivos.
- Mejorar seguridad.

---

## Hierro

El hierro representa progreso técnico y capacidad defensiva.

### Se genera con

- Comercio.
- Mina futura.
- Eventos de hallazgo.
- Expediciones.
- Chatarra o reciclaje futuro.

### Se consume por

- Herrería.
- Armas.
- Herramientas.
- Reparaciones avanzadas.
- Mejoras productivas.

### Uso jugable

- Desbloquear mejoras de herrería.
- Resolver quests de Aldric/Gareth.
- Preparar defensa.
- Mejorar producción de la aldea.

---

## Medicina

La medicina representa reservas sanitarias: hierbas, ungüentos, vendas, conocimiento práctico y material de cura.

### Se genera con

- Elowen / casa de curas futura.
- Hierbas de prados o bosque.
- Comercio.
- Eventos de recolección.

### Se consume por

- Enfermedades.
- Heridas.
- Combate.
- Accidentes de trabajo.
- Crisis sanitarias futuras.

### Uso jugable

- Curar habitantes.
- Reducir consecuencias de heridas.
- Evitar que eventos de enfermedad escalen.
- Dar peso mecánico a Elowen y a la casa de curas.

---

## Moral

La moral es el termómetro emocional de la aldea.

### Se genera con

- Taberna.
- Capilla.
- Buenas noticias.
- Comida suficiente.
- Relaciones positivas.
- Festivales futuros.
- Quests resueltas.

### Baja por

- Hambre.
- Muertes.
- Conflictos.
- Ataques.
- Impuestos futuros.
- Fracasos de quests.

### Uso jugable

- Mantener estabilidad.
- Evitar conflictos internos.
- Atraer habitantes.
- Reducir abandono.
- Modificar eventos sociales.

---

## Seguridad

La seguridad mide cuán protegida está Valdeniebla.

### Se genera con

- Herrería.
- Prados vigilados.
- Empalizada futura.
- Guardias futuros.
- Armas y patrullas.

### Baja por

- Ataques.
- Amenazas externas.
- Bandidos.
- Falta de vigilancia.
- Conflictos internos graves.

### Uso jugable

- Reducir riesgo de ataques.
- Proteger producción.
- Permitir expediciones.
- Atraer comercio.
- Dar base a combate y amenazas.

---

## Valores iniciales

Primera configuración recomendada:

| Recurso | Valor inicial |
|---|---:|
| Comida | 60 |
| Madera | 30 |
| Hierro | 10 |
| Medicina | 8 |
| Moral | 50 |
| Seguridad | 25 |

---

## Producción diaria inicial

| Edificio | Producción | Consumo | Nota |
|---|---:|---:|---|
| Granjas | +10 comida | - | Bran sostiene la comida base |
| Prados | +3 comida | - | Lysa aporta ganadería y vigilancia rural futura |
| Taberna | +1 moral | - | Mara mejora cohesión social y rumores |
| Capilla | +1 moral | - | Tomas reduce tensión social futura |
| Herrería | +1 seguridad | -1 hierro cada 3 días | Aldric/Gareth convierten hierro en defensa y herramientas |
| Pozo | -1 estrés medio | - | Estabilidad cotidiana, salud futura |

Consumo base:

| Consumo | Fórmula inicial |
|---|---:|
| Comida diaria | -1 por habitante |

Con 8 habitantes, la aldea consume -8 comida al día.

---

## Flujo diario

Al pulsar **Avanzar día**, el orden lógico es:

1. Avanzar calendario.
2. Aplicar producción base de edificios.
3. Aplicar consumo base de habitantes.
4. Aplicar costes periódicos, como hierro de herrería.
5. Resolver eventos del día.
6. Aplicar efectos de eventos sobre NPCs, relaciones y recursos.
7. Actualizar HUD, paneles, feed reciente y crónica.

Ejemplo:

```text
Día 7
Producción: +10 comida por Granjas, +3 comida por Prados, +2 moral por Taberna/Capilla
Consumo: -8 comida por habitantes
Evento: Bran mejora los surcos, +4 comida
Resultado neto: comida +9, moral +2
```

---

## Umbrales de crisis

### Comida

| Valor | Estado |
|---:|---|
| 40+ | Estable |
| 20-39 | Justa |
| 6-19 | Preocupante |
| 0-5 | Crisis |

### Moral

| Valor | Estado |
|---:|---|
| 70-100 | Alta |
| 40-69 | Estable |
| 20-39 | Baja |
| 0-19 | Riesgo social |

### Seguridad

| Valor | Estado |
|---:|---|
| 70-100 | Protegida |
| 40-69 | Vulnerable |
| 20-39 | Peligrosa |
| 0-19 | Amenaza inminente |

### Medicina

| Valor | Estado |
|---:|---|
| 20+ | Reserva suficiente |
| 6-19 | Limitada |
| 0-5 | Crítica |

---

## Relación con eventos

Los eventos pueden modificar recursos con efectos explícitos:

```gdscript
{"resource": "comida", "delta": 4}
{"resource": "moral", "delta": -2}
{"resource": "seguridad", "delta": 1}
```

Esto permite que los sucesos narrativos tengan peso sistémico.

---

## Relación con quests

Las quests futuras deben poder pedir o modificar recursos:

- Aldric puede necesitar hierro para una reparación importante.
- Elowen puede requerir medicina para tratar una fiebre.
- Oren puede gastar madera en reparar la casa comunal.
- Mara puede mejorar moral mediante eventos sociales.
- Lysa puede aumentar seguridad rural desde los prados.

---

## Qué queda fuera de la primera versión

No se implementa todavía:

- Oro.
- Piedra.
- Herramientas como recurso separado.
- Agua.
- Fe.
- Influencia política.
- Comercio completo.
- Construcción real de edificios.
- Asignación manual de trabajadores.
- Invierno.
- Combate.

Estos sistemas pueden añadirse cuando la economía base sea estable.
