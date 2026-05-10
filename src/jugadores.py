import psycopg2
import psycopg2.errors
from conexion import get_connection


# ── Helpers de catálogos ──────────────────────────────────────────────────────

def _listar_equipos(cur):
    cur.execute("SELECT id_equipo, nombre FROM equipos ORDER BY nombre")
    rows = cur.fetchall()
    print("\n  Equipos disponibles:")
    print(f"  {'ID':<5} {'Nombre'}")
    print("  " + "-" * 30)
    for r in rows:
        print(f"  {r[0]:<5} {r[1]}")


def _listar_posiciones(cur):
    cur.execute("SELECT id_posicion, nombre FROM posiciones ORDER BY nombre")
    rows = cur.fetchall()
    print("\n  Posiciones disponibles:")
    print(f"  {'ID':<5} {'Nombre'}")
    print("  " + "-" * 30)
    for r in rows:
        print(f"  {r[0]:<5} {r[1]}")


def _listar_nacionalidades(cur):
    cur.execute("SELECT id_nacionalidad, nombre FROM nacionalidades ORDER BY nombre")
    rows = cur.fetchall()
    print("\n  Nacionalidades disponibles:")
    print(f"  {'ID':<5} {'Nombre'}")
    print("  " + "-" * 30)
    for r in rows:
        print(f"  {r[0]:<5} {r[1]}")


def _leer_int(prompt, requerido=True):
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
    valor = input(prompt).strip()
    return valor if valor else None


# ── CRUD ──────────────────────────────────────────────────────────────────────

def listar_jugadores():
    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    j.id_jugador,
                    j.nombre || ' ' || j.apellido   AS jugador,
                    e.nombre                         AS equipo,
                    p.nombre                         AS posicion,
                    j.numero_camiseta,
                    COALESCE(n.nombre, 'N/A')        AS nacionalidad,
                    COALESCE(j.fecha_nacimiento::TEXT, 'N/A') AS nacimiento
                FROM jugadores j
                JOIN equipos      e ON j.id_equipo    = e.id_equipo
                JOIN posiciones   p ON j.id_posicion  = p.id_posicion
                LEFT JOIN nacionalidades n ON j.id_nacionalidad = n.id_nacionalidad
                ORDER BY e.nombre, j.apellido, j.nombre
            """)
            rows = cur.fetchall()
            if not rows:
                print("\n  No hay jugadores registrados.")
                return
            print()
            print(f"  {'ID':<5} {'Jugador':<28} {'Equipo':<22} {'Posición':<20} {'#':<4} {'Nacionalidad':<18} {'Nacimiento'}")
            print("  " + "-" * 110)
            for r in rows:
                print(f"  {r[0]:<5} {r[1]:<28} {r[2]:<22} {r[3]:<20} {r[4]:<4} {r[5]:<18} {r[6]}")
    except psycopg2.Error as e:
        print(f"\n  Error al consultar jugadores: {e}")
    finally:
        conn.close()


def crear_jugador():
    print("\n--- Crear jugador ---")
    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            _listar_equipos(cur)
            _listar_posiciones(cur)
            _listar_nacionalidades(cur)

        nombre          = _leer_texto("\n  Nombre: ", requerido=True)
        apellido        = _leer_texto("  Apellido: ", requerido=True)
        id_equipo       = _leer_int("  ID del equipo: ", requerido=True)
        id_posicion     = _leer_int("  ID de la posición: ", requerido=True)
        numero_camiseta = _leer_int("  Número de camiseta (1-99): ", requerido=True)
        id_nacionalidad = _leer_int("  ID de nacionalidad (Enter para omitir): ", requerido=False)
        fecha_nac       = _leer_fecha("  Fecha de nacimiento YYYY-MM-DD (Enter para omitir): ")

        with conn.cursor() as cur:
            # El campo id_jugador (SERIAL) NO se incluye: la BD lo genera automáticamente.
            cur.execute("""
                INSERT INTO jugadores
                    (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nacimiento)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id_jugador
            """, (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nac))
            nuevo_id = cur.fetchone()[0]
        conn.commit()
        print(f"\n  Jugador creado correctamente con ID {nuevo_id}.")

    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        print(f"\n  Error: ese número de camiseta ya está asignado a otro jugador del mismo equipo.")
    except psycopg2.errors.NotNullViolation as e:
        conn.rollback()
        print(f"\n  Error: campo obligatorio sin valor. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.ForeignKeyViolation as e:
        conn.rollback()
        print(f"\n  Error: el equipo, posición o nacionalidad indicado no existe. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.CheckViolation as e:
        conn.rollback()
        print(f"\n  Error: violación de restricción (ej. número de camiseta fuera del rango 1-99). Detalle: {e.diag.message_primary}")
    except psycopg2.errors.DataError as e:
        conn.rollback()
        print(f"\n  Error: tipo de dato incorrecto (ej. fecha mal formateada). Detalle: {e.diag.message_primary}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()


def actualizar_jugador():
    print("\n--- Actualizar jugador ---")
    listar_jugadores()

    id_jugador = _leer_int("\n  ID del jugador a actualizar: ", requerido=True)

    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            _listar_equipos(cur)
            _listar_posiciones(cur)
            _listar_nacionalidades(cur)

        print("\n  Ingrese los nuevos valores (Enter para no modificar el campo):")
        nombre          = _leer_texto("  Nombre: ", requerido=False)
        apellido        = _leer_texto("  Apellido: ", requerido=False)
        id_equipo_str   = input("  ID equipo: ").strip()
        id_posicion_str = input("  ID posición: ").strip()
        num_cam_str     = input("  Número de camiseta (1-99): ").strip()
        id_nac_str      = input("  ID nacionalidad: ").strip()
        fecha_nac       = _leer_fecha("  Fecha de nacimiento YYYY-MM-DD: ")

        campos, valores = [], []
        if nombre:
            campos.append("nombre = %s");            valores.append(nombre)
        if apellido:
            campos.append("apellido = %s");          valores.append(apellido)
        if id_equipo_str:
            try:
                campos.append("id_equipo = %s");     valores.append(int(id_equipo_str))
            except ValueError:
                print("  Error: ID de equipo debe ser entero. Campo ignorado.")
        if id_posicion_str:
            try:
                campos.append("id_posicion = %s");   valores.append(int(id_posicion_str))
            except ValueError:
                print("  Error: ID de posición debe ser entero. Campo ignorado.")
        if num_cam_str:
            try:
                campos.append("numero_camiseta = %s"); valores.append(int(num_cam_str))
            except ValueError:
                print("  Error: número de camiseta debe ser entero. Campo ignorado.")
        if id_nac_str:
            try:
                campos.append("id_nacionalidad = %s"); valores.append(int(id_nac_str))
            except ValueError:
                print("  Error: ID de nacionalidad debe ser entero. Campo ignorado.")
        if fecha_nac:
            campos.append("fecha_nacimiento = %s");  valores.append(fecha_nac)

        if not campos:
            print("\n  No se modificó ningún campo.")
            return

        valores.append(id_jugador)
        with conn.cursor() as cur:
            cur.execute(
                f"UPDATE jugadores SET {', '.join(campos)} WHERE id_jugador = %s",
                valores
            )
            if cur.rowcount == 0:
                print(f"\n  No existe un jugador con ID {id_jugador}.")
                conn.rollback()
                return
        conn.commit()
        print("\n  Jugador actualizado correctamente.")

    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        print("\n  Error: ese número de camiseta ya está asignado a otro jugador del mismo equipo.")
    except psycopg2.errors.NotNullViolation as e:
        conn.rollback()
        print(f"\n  Error: campo obligatorio sin valor. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.ForeignKeyViolation as e:
        conn.rollback()
        print(f"\n  Error: el equipo, posición o nacionalidad indicado no existe. Detalle: {e.diag.message_primary}")
    except psycopg2.errors.CheckViolation as e:
        conn.rollback()
        print(f"\n  Error: violación de restricción (ej. número de camiseta fuera del rango 1-99). Detalle: {e.diag.message_primary}")
    except psycopg2.errors.DataError as e:
        conn.rollback()
        print(f"\n  Error: tipo de dato incorrecto. Detalle: {e.diag.message_primary}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()


def eliminar_jugador():
    print("\n--- Eliminar jugador ---")
    listar_jugadores()

    id_jugador = _leer_int("\n  ID del jugador a eliminar: ", requerido=True)
    confirmar  = input(f"  ¿Confirmar eliminación del jugador {id_jugador}? (s/n): ").strip().lower()
    if confirmar != "s":
        print("  Operación cancelada.")
        return

    conn = get_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM jugadores WHERE id_jugador = %s", (id_jugador,))
            if cur.rowcount == 0:
                print(f"\n  No existe un jugador con ID {id_jugador}.")
                conn.rollback()
                return
        conn.commit()
        print("\n  Jugador eliminado correctamente.")

    except psycopg2.errors.ForeignKeyViolation:
        conn.rollback()
        print("\n  Error: no se puede eliminar el jugador porque tiene registros asociados en otras tablas.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"\n  Error inesperado: {e}")
    finally:
        conn.close()
