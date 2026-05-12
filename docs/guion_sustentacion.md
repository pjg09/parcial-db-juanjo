# Guión de sustentación — 26 de mayo de 2026

Duración del turno: **20 minutos**  
Comando para arrancar: `cd src && python3 main.py`  
Comando para resetear datos: `PGPASSWORD=chepa123 psql -U postgres -h localhost -d torneos_db -f sql/seed.sql`

---

## Orden sugerido (20 min)

| Tiempo | Bloque | Qué mostrar |
|---|---|---|
| 0–4 min | BD en psql | Tablas, relaciones, constraints, índices |
| 4–7 min | SPs y Triggers | Código y explicación |
| 7–18 min | Demo Python | CRUD + todas las excepciones |
| 18–20 min | Preguntas | Cierre |

---

## Bloque 1 — Base de datos (psql) · 4 min

### Mostrar las tablas
```sql
\dt
```
**Explicar:** 11 tablas en total — 5 catálogo (paises, ciudades, nacionalidades, entrenadores, posiciones) y 6 principales. Cumple formas normales: no hay datos repetidos, los catálogos centralizan la información reutilizable.

### Mostrar estructura de una tabla con relaciones
```sql
\d equipos
\d jugadores
```
**Explicar:** se ven las FKs declaradas, los NOT NULL, los UNIQUE. PostgreSQL garantiza integridad referencial automáticamente.

### Mostrar índices
```sql
\di
```
**Señalar:** los `idx_*` son los índices explícitos que creamos. Los `uq_*` y `_pkey` son automáticos de los constraints.

### Mostrar tabla de posiciones (datos reales del seed)
```sql
SELECT e.nombre, tp.puntos, tp.partidos_jugados, tp.goles_favor, tp.goles_contra, tp.diferencia_goles
FROM tabla_posiciones tp
JOIN equipos e ON tp.id_equipo = e.id_equipo
JOIN torneos t ON tp.id_torneo = t.id_torneo
WHERE t.nombre = 'Liga Apertura 2025'
ORDER BY tp.puntos DESC;
```

---

## Bloque 2 — Stored Procedures y Triggers · 3 min

### Mostrar el código
```sql
\sf inscribir_equipo_torneo
\sf registrar_resultado
\sf fn_validar_fecha_partido
\sf fn_recalcular_diferencia_goles
```

### Explicar cada uno
- **`inscribir_equipo_torneo`**: crea la fila en tabla_posiciones para un equipo en un torneo. Lanza excepción si ya está inscrito.
- **`registrar_resultado`**: calcula puntos (3/1/0), actualiza estadísticas de ambos equipos, marca el partido como jugado.
- **`trg_validar_fecha_partido`** (BEFORE INSERT/UPDATE en partidos): rechaza partidos con fecha fuera del rango del torneo.
- **`trg_recalcular_diferencia_goles`** (BEFORE UPDATE en tabla_posiciones): mantiene `diferencia_goles = goles_favor - goles_contra` siempre consistente.

### Demostrar el trigger de fecha en vivo
```sql
-- Esto debe FALLAR con el mensaje del trigger:
INSERT INTO partidos (id_torneo, id_equipo_local, id_equipo_visitante, fecha_partido)
VALUES (1, 1, 2, '2030-01-01 10:00:00');
```

---

## Bloque 3 — Demo Python CRUD · 11 min

Arrancar el programa:
```
cd src
python3 main.py
```

### 3.1 — CRUD normal (equipos) · 2 min
1. **Listar** → mostrar los equipos del seed
2. **Crear** → ingresar un equipo nuevo válido (ej. "Santa Fe", ciudad Bogotá)
3. **Actualizar** → cambiar el nombre del equipo recién creado
4. **Eliminar** → eliminar el equipo recién creado (no tiene hijos → debe funcionar)

### 3.2 — CRUD normal (jugadores) · 2 min
1. **Listar** → mostrar jugadores
2. **Crear** → ingresar un jugador válido para un equipo existente
3. **Actualizar** → cambiar número de camiseta
4. **Eliminar** → eliminar el jugador recién creado

### 3.3 — Provocar excepciones (sin que el programa cancele) · 7 min

#### Violación de UNIQUE (PK/nombre duplicado)
- Crear equipo → nombre: `Atlético Nacional` (ya existe)
- **Mensaje esperado:** `Error: ya existe un equipo con el nombre 'Atlético Nacional'.`

#### Violación de NOT NULL (campo obligatorio)
- Crear equipo → nombre: *(Enter sin escribir nada)*
- **Mensaje esperado:** `Este campo es obligatorio.` (validación Python antes de llegar a la BD)

#### Violación de tipo de dato
- Crear equipo → ID ciudad: `abc`
- **Mensaje esperado:** `Error: debe ingresar un número entero.`

#### Campo SERIAL / Identity
- **Explicar:** el campo `id_equipo` es SERIAL — nunca se le pregunta al usuario ni se incluye en el INSERT. La BD lo genera automáticamente. Mostrar el código en `equipos.py` línea del INSERT.

#### Violación de CHECK constraint
- Crear jugador → número de camiseta: `150`
- **Mensaje esperado:** `Error: violación de restricción (ej. número de camiseta fuera del rango 1-99).`

#### Violación de FK al borrar (integridad referencial)
- Eliminar equipo → ID: `1` (Atlético Nacional, tiene jugadores y partidos)
- **Mensaje esperado:** `Error: no se puede eliminar el equipo porque tiene jugadores, partidos u otros registros asociados.`

#### Violación de UNIQUE en jugadores
- Crear jugador en Atlético Nacional → número de camiseta: `1` (ya tiene portero con #1)
- **Mensaje esperado:** `Error: ese número de camiseta ya está asignado a otro jugador del mismo equipo.`

---

## Preguntas frecuentes del profesor

**¿Por qué usaron tablas catálogo?**  
Para cumplir 3FN: datos que se repiten (países, posiciones, nacionalidades) se centralizan en una tabla propia y se referencian por ID. Evita redundancia y facilita actualizaciones.

**¿Cuál es la diferencia entre un SP y un trigger?**  
El SP se llama explícitamente (`CALL`). El trigger se dispara automáticamente ante un evento (INSERT/UPDATE/DELETE) sin que el código lo invoque.

**¿Por qué el trigger de diferencia de goles es BEFORE y no AFTER?**  
Porque necesita modificar el valor de `NEW` antes de que se escriba en disco. Un AFTER trigger ya no puede cambiar la fila que se está insertando/actualizando.

**¿Cómo manejan el campo SERIAL para que no se pueda ingresar desde el programa?**  
Simplemente no se incluye en el INSERT. Python nunca le pide el ID al usuario y el SQL no lo menciona — la BD asigna el siguiente valor de la secuencia automáticamente.

**¿Qué pasa si se intenta inscribir dos veces el mismo equipo en un torneo?**  
El SP `inscribir_equipo_torneo` verifica con un `IF EXISTS` antes de insertar y lanza `RAISE EXCEPTION` con un mensaje descriptivo.

---

## Checklist antes de entrar a sustentar

- [ ] Docker corriendo: `docker ps | grep chepa_postgres`
- [ ] Seed ejecutado limpio: `PGPASSWORD=chepa123 psql -U postgres -h localhost -d torneos_db -f sql/seed.sql`
- [ ] Programa arranca: `cd src && python3 main.py`
- [ ] psql conecta: `PGPASSWORD=chepa123 psql -U postgres -h localhost -d torneos_db`
- [ ] Todos los integrantes pueden explicar cada parte
