# Esquema de la base de datos

## Diagrama de tablas

```
paises ──< ciudades ──< equipos >── entrenadores
                           │              │
                        jugadores    nacionalidades
                           │
                       posiciones

nacionalidades ──< arbitros ──< partidos >── equipos
torneos ──────────────────────< partidos
torneos ──< tabla_posiciones >── equipos
```

---

## Tablas catálogo

### C1. `paises`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_pais | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE |
| codigo_iso | CHAR(3) | NOT NULL, UNIQUE |

---

### C2. `ciudades`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_ciudad | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL |
| id_pais | INT | FK → paises(id_pais), NOT NULL |

**Constraints:**
- `uq_ciudad_pais`: UNIQUE (nombre, id_pais)

---

### C3. `nacionalidades`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_nacionalidad | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE |
| codigo_iso | CHAR(3) | NOT NULL, UNIQUE |

---

### C4. `entrenadores`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_entrenador | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL |
| apellido | VARCHAR(100) | NOT NULL |
| id_nacionalidad | INT | FK → nacionalidades(id_nacionalidad) |

---

### C5. `posiciones`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_posicion | SERIAL | PK |
| nombre | VARCHAR(50) | NOT NULL, UNIQUE |
| descripcion | VARCHAR(150) | |

Ejemplos de valores: Portero, Defensa Central, Lateral Derecho, Mediocampista, Delantero, etc.

---

## Tablas principales

### 1. `torneos`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_torneo | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE |
| fecha_inicio | DATE | NOT NULL |
| fecha_fin | DATE | NOT NULL |
| descripcion | VARCHAR(255) | |

**Constraints:**
- `chk_fechas_torneo`: `fecha_fin > fecha_inicio`

---

### 2. `equipos`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_equipo | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE |
| id_ciudad | INT | FK → ciudades(id_ciudad), NOT NULL |
| fecha_fundacion | DATE | |
| id_entrenador | INT | FK → entrenadores(id_entrenador) |

---

### 3. `jugadores`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_jugador | SERIAL | PK |
| id_equipo | INT | FK → equipos(id_equipo), NOT NULL |
| id_nacionalidad | INT | FK → nacionalidades(id_nacionalidad) |
| id_posicion | INT | FK → posiciones(id_posicion), NOT NULL |
| nombre | VARCHAR(100) | NOT NULL |
| apellido | VARCHAR(100) | NOT NULL |
| numero_camiseta | INT | NOT NULL |
| fecha_nacimiento | DATE | |

**Constraints:**
- `chk_numero_camiseta`: `numero_camiseta BETWEEN 1 AND 99`
- `uq_camiseta_equipo`: UNIQUE (id_equipo, numero_camiseta)

---

### 4. `arbitros`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_arbitro | SERIAL | PK |
| nombre | VARCHAR(100) | NOT NULL |
| apellido | VARCHAR(100) | NOT NULL |
| id_nacionalidad | INT | FK → nacionalidades(id_nacionalidad) |

---

### 5. `partidos`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_partido | SERIAL | PK |
| id_torneo | INT | FK → torneos(id_torneo), NOT NULL |
| id_equipo_local | INT | FK → equipos(id_equipo), NOT NULL |
| id_equipo_visitante | INT | FK → equipos(id_equipo), NOT NULL |
| id_arbitro | INT | FK → arbitros(id_arbitro) |
| fecha_partido | TIMESTAMP | NOT NULL |
| goles_local | INT | DEFAULT 0 |
| goles_visitante | INT | DEFAULT 0 |
| jugado | BOOLEAN | DEFAULT FALSE |

**Constraints:**
- `chk_equipos_distintos`: `id_equipo_local <> id_equipo_visitante`
- `chk_goles_local`: `goles_local >= 0`
- `chk_goles_visitante`: `goles_visitante >= 0`

---

### 6. `tabla_posiciones`
| Columna | Tipo | Restricciones |
|---|---|---|
| id_tabla | SERIAL | PK |
| id_torneo | INT | FK → torneos(id_torneo), NOT NULL |
| id_equipo | INT | FK → equipos(id_equipo), NOT NULL |
| puntos | INT | DEFAULT 0 |
| partidos_jugados | INT | DEFAULT 0 |
| partidos_ganados | INT | DEFAULT 0 |
| partidos_empatados | INT | DEFAULT 0 |
| partidos_perdidos | INT | DEFAULT 0 |
| goles_favor | INT | DEFAULT 0 |
| goles_contra | INT | DEFAULT 0 |
| diferencia_goles | INT | DEFAULT 0 |

**Constraints:**
- `uq_equipo_torneo`: UNIQUE (id_torneo, id_equipo)
- `chk_puntos_positivos`: `puntos >= 0`

---

## Resumen de tablas

| # | Tabla | Tipo |
|---|---|---|
| C1 | paises | Catálogo |
| C2 | ciudades | Catálogo |
| C3 | nacionalidades | Catálogo |
| C4 | entrenadores | Catálogo |
| C5 | posiciones | Catálogo |
| 1 | torneos | Principal |
| 2 | equipos | Principal |
| 3 | jugadores | Principal |
| 4 | arbitros | Principal |
| 5 | partidos | Principal |
| 6 | tabla_posiciones | Relación / Estadística |

**Total: 11 tablas** (supera ampliamente el mínimo de 5 del examen)

---

## Índices

| Índice | Tabla | Campo(s) | Tipo | Justificación |
|---|---|---|---|---|
| `idx_jugadores_equipo` | jugadores | id_equipo | BTREE | Búsquedas frecuentes de jugadores por equipo |
| `idx_jugadores_posicion` | jugadores | id_posicion | BTREE | Filtrar jugadores por posición |
| `idx_partidos_torneo` | partidos | id_torneo | BTREE | Filtrar partidos de un torneo |
| `idx_partidos_fecha` | partidos | fecha_partido | BTREE | Ordenar/filtrar por fecha |
| `idx_tabla_torneo` | tabla_posiciones | id_torneo | BTREE | Obtener clasificación de un torneo |

---

## Stored Procedures

### SP1: `registrar_resultado(id_partido, goles_local, goles_visitante)`
Registra el resultado de un partido y actualiza `tabla_posiciones` para ambos equipos:
- Suma puntos (3 ganador, 1 empate, 0 perdedor)
- Incrementa `partidos_jugados`, `goles_favor`, `goles_contra`, `diferencia_goles`
- Marca el partido como `jugado = TRUE`

### SP2: `inscribir_equipo_torneo(id_torneo, id_equipo)`
Inscribe un equipo en un torneo creando su fila en `tabla_posiciones` con todos los valores en 0. Verifica que el equipo no esté ya inscrito.

---

## Triggers

### TRG1: `trg_validar_fecha_partido`
**Evento:** BEFORE INSERT OR UPDATE en `partidos`
**Acción:** Verifica que `fecha_partido` esté dentro del rango `fecha_inicio`–`fecha_fin` del torneo. Si no, lanza excepción.

### TRG2: `trg_recalcular_diferencia_goles`
**Evento:** AFTER UPDATE en `tabla_posiciones`
**Acción:** Recalcula automáticamente `diferencia_goles = goles_favor - goles_contra` para mantener consistencia.

---

## Tablas para CRUD (Python)

Se implementará CRUD completo con manejo de excepciones para:
1. **`equipos`** — alta, consulta, modificación y baja de equipos
2. **`jugadores`** — alta, consulta, modificación y baja de jugadores

### Excepciones a manejar
| Situación | Excepción PostgreSQL | Manejo |
|---|---|---|
| Violación de PK / UNIQUE | `UniqueViolation` | Mensaje al usuario, no cancela |
| Tipo de dato incorrecto | `DataError` | Mensaje al usuario, no cancela |
| Campo obligatorio vacío | `NotNullViolation` | Mensaje al usuario, no cancela |
| Campo SERIAL / Identity | Validación previa en Python | No enviar el campo en el INSERT |
| Violación de constraint | `CheckViolation` | Mensaje al usuario, no cancela |
| Borrar con hijos (FK) | `ForeignKeyViolation` | Mensaje al usuario, no cancela |
