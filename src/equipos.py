import psycopg2
import psycopg2.errors
from conexion import get_connection


# ── Helpers de catálogos ──────────────────────────────────────────────────────

def _listar_ciudades(cur):
    cur.execute("""
        SELECT c.id_ciudad, c.nombre, p.nombre
        FROM ciudades c
        JOIN paises p ON c.id_pais = p.id_pais
        ORDER BY p.nombre, c.nombre
    """)
    rows = cur.fetchall()
    print("\n  Ciudades disponibles:")
    print(f"  {'ID':<5} {'Ciudad':<25} {'País'}")
    print("  " + "-" * 45)
    for r in rows:
        print(f"  {r[0]:<5} {r[1]:<25} {r[2]}")


def _listar_entrenadores(cur):
    cur.execute("""
        SELECT id_entrenador, nombre, apellido
        FROM entrenadores
        ORDER BY apellido, nombre
    """)
    rows = cur.fetchall()
    print("\n  Entrenadores disponibles:")
    print(f"  {'ID':<5} {'Nombre'}")
    print("  " + "-" * 30)
    for r in rows:
        print(f"  {r[0]:<5} {r[1]} {r[2]}")


def _leer_int(prompt, requerido=True):
    """Lee un entero del usuario. Retorna None si no es requerido y el usuario no ingresa nada."""
    while True:
        valor = input(prompt).strip()
        if not valor:
            if requerido:
                print("  Este campo es obligatorio.")
                continue
            return None
        try:
            return int(valor)
        except ValueError:
            print("  Error: debe ingresar un número entero.")


def _leer_texto(prompt, requerido=True):
    while True:
        valor = input(prompt).strip()
        if not valor and requerido:
            print("  Este campo es obligatorio.")
            continue
        return valor or None


def _leer_fecha(prompt):
    """Lee una fecha opcional en formato YYYY-MM-DD."""
    valor = input(prompt).strip()
    return valor if valor else None


# ── CRUD ──────────────────────────────────────────────────────────────────────

def listar_equipos():
    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    e.id_equipo,
                    e.nombre,
                    c.nombre        AS ciudad,
                    p.nombre        AS pais,
                    COALESCE(en.nombre || ' ' || en.apellido, 'Sin entrenador') AS entrenador,
                    COALESCE(e.fecha_fundacion::TEXT, 'N/A') AS fundacion
                FROM equipos e
                JOIN ciudades    c  ON e.id_ciudad     = c.id_ciudad
                JOIN paises      p  ON c.id_pais        = p.id_pais
                LEFT JOIN entrenadores en ON e.id_entrenador = en.id_entrenador
                ORDER BY e.nombre
            """)
            rows = cur.fetchall()
            if not rows:
                print("\n  No hay equipos registrados.")
                return
            print()
            print(f"  {'ID':<5} {'Nombre':<25} {'Ciudad':<20} {'País':<15} {'Entrenador':<25} {'Fundación'}")
            print("  " + "-" * 100)
            for r in rows:
                print(f"  {r[0]:<5} {r[1]:<25} {r[2]:<20} {r[3]:<15} {r[4]:<25} {r[5]}")
    except psycopg2.Error as e:
        print(f"\n  Error al consultar equipos: {e}")
    finally:
        conn.close()


def crear_equipo():
    print("\n--- Crear equipo ---")
    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            _listar_ciudades(cur)
            _listar_entrenadores(cur)

        nombre       = _leer_texto("\n  Nombre del equipo: ", requerido=True)
        id_ciudad    = _leer_int("  ID de la ciudad: ", requerido=True)
        fecha_fund   = _leer_fecha("  Fecha de fundación YYYY-MM-DD (Enter para omitir): ")
        id_entrenador = _leer_int("  ID del entrenador (Enter para omitir): ", requerido=False)

        with conn.cursor() as cur:
            # El campo id_equipo (SERIAL) NO se incluye: la BD lo genera automáticamente.
            cur.execute("""
                INSERT INTO equipos (nombre, id_ciudad, fecha_fundacion, id_entrenador)
                VALUES (%s, %s, %s, %s)
                RETURNING id_equipo
            """, (nombre, id_ciudad, fecha_fund, id_entrenador))
            nuevo_id = cur.fetchone()[0]
        conn.commit()
        print(f"\n  Equipo creado correctamente con ID {nuevo_id}.")

    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        print(f"\n  Error: ya existe un equipo con el nombre '{nombre}'.")
    except psycopg2.errors.NotNullViolation as e:
        conn.rollback()
        print(f"\n  Error: campo obligatorio sin valor. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.ForeignKeyViolation as e:
        conn.rollback()
        print(f"\n  Error: la ciudad o el entrenador indicado no existe. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.CheckViolation as e:
        conn.rollback()
        print(f"\n  Error: violación de restricción. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.DataError as e:
        conn.rollback()
        print(f"\n  Error: tipo de dato incorrecto (ej. fecha mal formateada). Detalle: {e.diag.message_primary}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()


def actualizar_equipo():
    print("\n--- Actualizar equipo ---")
    listar_equipos()

    id_equipo = _leer_int("\n  ID del equipo a actualizar: ", requerido=True)

    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            _listar_ciudades(cur)
            _listar_entrenadores(cur)

        print("\n  Ingrese los nuevos valores (Enter para no modificar el campo):")
        nombre        = _leer_texto("  Nombre: ", requerido=False)
        id_ciudad_str = input("  ID ciudad: ").strip()
        fecha_fund    = _leer_fecha("  Fecha de fundación YYYY-MM-DD: ")
        id_ent_str    = input("  ID entrenador: ").strip()

        campos, valores = [], []
        if nombre:
            campos.append("nombre = %s");         valores.append(nombre)
        if id_ciudad_str:
            try:
                campos.append("id_ciudad = %s");  valores.append(int(id_ciudad_str))
            except ValueError:
                print("  Error: ID de ciudad debe ser entero. Campo ignorado.")
        if fecha_fund:
            campos.append("fecha_fundacion = %s"); valores.append(fecha_fund)
        if id_ent_str:
            try:
                campos.append("id_entrenador = %s"); valores.append(int(id_ent_str))
            except ValueError:
                print("  Error: ID de entrenador debe ser entero. Campo ignorado.")

        if not campos:
            print("\n  No se modificó ningún campo.")
            return

        valores.append(id_equipo)
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE equipos SET {', '.join(campos)} WHERE id_equipo = %s",
                valores
            )
            if cur.rowcount == 0:
                print(f"\n  No existe un equipo con ID {id_equipo}.")
                conn.rollback()
                return
        conn.commit()
        print("\n  Equipo actualizado correctamente.")

    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        print("\n  Error: ya existe un equipo con ese nombre.")
    except psycopg2.errors.NotNullViolation as e:
        conn.rollback()
        print(f"\n  Error: campo obligatorio sin valor. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.ForeignKeyViolation as e:
        conn.rollback()
        print(f"\n  Error: la ciudad o el entrenador indicado no existe. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.CheckViolation as e:
        conn.rollback()
        print(f"\n  Error: violación de restricción. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.DataError as e:
        conn.rollback()
        print(f"\n  Error: tipo de dato incorrecto. Detalle: {e.diag.message_primary}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()


def eliminar_equipo():
    print("\n--- Eliminar equipo ---")
    listar_equipos()

    id_equipo = _leer_int("\n  ID del equipo a eliminar: ", requerido=True)
    confirmar = input(f"  ¿Confirmar eliminación del equipo {id_equipo}? (s/n): ").strip().lower()
    if confirmar != "s":
        print("  Operación cancelada.")
        return

    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM equipos WHERE id_equipo = %s", (id_equipo,))
            if cur.rowcount == 0:
                print(f"\n  No existe un equipo con ID {id_equipo}.")
                conn.rollback()
                return
        conn.commit()
        print("\n  Equipo eliminado correctamente.")

    except psycopg2.errors.ForeignKeyViolation:
        conn.rollback()
        print("\n  Error: no se puede eliminar el equipo porque tiene jugadores, partidos u otros registros asociados.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()
