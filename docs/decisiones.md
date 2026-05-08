# Decisiones del proyecto

## Stack tecnológico

| Componente | Elección | Justificación |
|---|---|---|
| Base de datos | PostgreSQL | Open source, portable, soporte completo para SP, triggers, constraints e índices |
| Lenguaje | Python | Menos boilerplate, manejo de excepciones legible, fácil de demostrar en vivo |
| Driver DB | psycopg2 | Librería estándar de Python para PostgreSQL |

## Temática

**Gestión de torneos deportivos**

Se eligió esta temática porque permite:
- Constraints naturales (puntos no negativos, equipo no juega contra sí mismo, fechas coherentes)
- Triggers con lógica real (actualizar tabla de posiciones al registrar resultado)
- Stored procedures con sentido (registrar resultado, calcular clasificación)

## Requisitos del examen

| Requisito | Estado |
|---|---|
| Al menos 5 tablas con buenas prácticas | Pendiente |
| Integridad referencial + formas normales | Pendiente |
| Constraints en al menos 3 campos | Pendiente |
| Índices en al menos 2 campos | Pendiente |
| Al menos 2 stored procedures | Pendiente |
| Al menos 2 triggers | Pendiente |
| CRUD en 2 tablas (Python) con manejo de excepciones | Pendiente |

## Fecha de entrega

Demostración en vivo: **26 de mayo de 2026**
