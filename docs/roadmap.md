# Hoja de ruta — Parcial de Bases de Datos

**Fecha de sustentación:** 26 de mayo de 2026  
**Duración del turno:** 20 minutos  
**Stack:** PostgreSQL 18 (Docker) + Python

---

## Checklist de requisitos del enunciado

### Base de datos

| Requisito | Detalle | Estado |
|---|---|---|
| Al menos 5 tablas | 11 tablas: 5 catálogo + 6 principales | ✅ Completo |
| Buenas prácticas de diseño | Nombres consistentes, PKs SERIAL, FKs explícitas, sin redundancia | ✅ Completo |
| Integridad referencial | Todas las FKs declaradas con REFERENCES | ✅ Completo |
| Formas normales | 1FN, 2FN y 3FN cumplidas; catálogos para ciudades, países, nacionalidades, entrenadores y posiciones | ✅ Completo |
| Constraints en al menos 3 campos | `chk_fechas_torneo`, `chk_equipos_distintos`, `chk_goles_local`, `chk_goles_visitante`, `chk_numero_camiseta`, `chk_puntos_positivos`, `uq_ciudad_pais`, `uq_camiseta_equipo`, `uq_equipo_torneo` | ✅ Completo |
| Índices en al menos 2 campos | 5 índices BTREE: jugadores(id_equipo), jugadores(id_posicion), partidos(id_torneo), partidos(fecha_partido), tabla_posiciones(id_torneo) | ✅ Completo |
| Al menos 2 stored procedures | `inscribir_equipo_torneo`, `registrar_resultado` | ✅ Completo |
| Al menos 2 triggers | `trg_validar_fecha_partido`, `trg_recalcular_diferencia_goles` | ✅ Completo |

---

### Aplicación Python (CRUD)

| Requisito | Detalle | Estado |
|---|---|---|
| CRUD tabla 1: `equipos` | Crear, leer, actualizar, eliminar equipos | ✅ Completo |
| CRUD tabla 2: `jugadores` | Crear, leer, actualizar, eliminar jugadores | ✅ Completo |
| Manejo: violación de PK/UNIQUE | Capturar `UniqueViolation` de psycopg2 | ✅ Completo |
| Manejo: violación de tipo de dato | Capturar `DataError` | ✅ Completo |
| Manejo: campo obligatorio vacío | Capturar `NotNullViolation` | ✅ Completo |
| Manejo: campo SERIAL/Identity | El ID nunca se incluye en el INSERT; la BD lo genera sola | ✅ Completo |
| Manejo: violación de constraint | Capturar `CheckViolation` | ✅ Completo |
| Manejo: violación de IR al borrar | Capturar `ForeignKeyViolation` | ✅ Completo |
| Programa nunca cancela | Todos los errores atrapados, flujo continúa siempre | ✅ Completo |

---

## Fases del proyecto

### ✅ Fase 1 — Diseño y documentación
- [x] Definición del stack (PostgreSQL + Python)
- [x] Elección de temática (Gestión de torneos)
- [x] Diseño del esquema: 11 tablas con relaciones, constraints e índices
- [x] Documentación en `docs/esquema.md` y `docs/decisiones.md`

### ✅ Fase 2 — Base de datos
- [x] Script SQL de creación (`sql/create_db.sql`)
- [x] Tablas catálogo y principales creadas
- [x] Índices, constraints e integridad referencial aplicados
- [x] Stored procedures implementados
- [x] Triggers implementados
- [x] BD ejecutada y verificada contra contenedor Docker

### ✅ Fase 3 — Aplicación Python
- [x] Estructura del proyecto Python (`src/`)
- [x] Módulo de conexión a PostgreSQL con `psycopg2` + `python-dotenv` (`src/conexion.py`)
- [x] CRUD completo para `equipos` (`src/equipos.py`)
- [x] CRUD completo para `jugadores` (`src/jugadores.py`)
- [x] Manejo de todas las excepciones requeridas por el enunciado
- [x] Menú de consola para demostrar el CRUD en vivo (`src/main.py`)
- [x] `requirements.txt` y `.env` / `.env.example` creados
- [x] Verificado: programa arranca, conecta a la BD y navega sin errores

### ✅ Fase 4 — Datos de prueba
- [x] Script SQL con datos de prueba (`sql/seed.sql`) — re-ejecutable con TRUNCATE al inicio
- [x] 6 países, 7 nacionalidades, 8 ciudades, 10 posiciones, 6 entrenadores
- [x] 2 torneos, 6 equipos, 4 árbitros, 21 jugadores, 6 partidos
- [x] SPs ejecutados: 8 inscripciones + 3 resultados registrados
- [x] Tabla de posiciones calculada y verificada (trigger diferencia de goles activo)

### ⏳ Fase 5 — Preparación para sustentación
- [ ] Verificar que todo corre en el computador de presentación
- [ ] Repasar explicación de cada elemento: tablas, relaciones, índices, constraints, SPs, triggers
- [ ] Practicar demostración del CRUD provocando cada tipo de excepción
- [ ] Acordar turno con el profesor para el 26 de mayo

---

## Estructura del proyecto

```
parcial-db-juanjo/
├── docs/
│   ├── decisiones.md       ✅ Stack, temática y requisitos
│   ├── esquema.md          ✅ Tablas, índices, SPs, triggers
│   └── roadmap.md          ✅ Este archivo
├── sql/
│   ├── create_db.sql       ✅ Creación completa de la BD
│   └── seed.sql            ✅ Datos de prueba
├── src/
│   ├── conexion.py         ✅ Módulo de conexión
│   ├── equipos.py          ✅ CRUD equipos
│   ├── jugadores.py        ✅ CRUD jugadores
│   └── main.py             ✅ Menú principal
├── .gitignore              ✅
├── .env.example            ✅
├── requirements.txt        ✅
└── README.md               ✅
```
