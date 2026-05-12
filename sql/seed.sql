-- =============================================================
--  Datos de prueba — Gestión de Torneos
--  Re-ejecutable: limpia todo antes de insertar.
-- =============================================================

TRUNCATE TABLE
    tabla_posiciones, partidos, jugadores,
    equipos, arbitros, entrenadores, torneos,
    posiciones, ciudades, nacionalidades, paises
RESTART IDENTITY CASCADE;

-- =============================================================
--  CATÁLOGOS
-- =============================================================

INSERT INTO paises (nombre, codigo_iso) VALUES
    ('Colombia',   'COL'),
    ('Argentina',  'ARG'),
    ('Brasil',     'BRA'),
    ('España',     'ESP'),
    ('Uruguay',    'URY'),
    ('Chile',      'CHL');

INSERT INTO nacionalidades (nombre, codigo_iso) VALUES
    ('Colombiano', 'COL'),
    ('Argentino',  'ARG'),
    ('Brasileño',  'BRA'),
    ('Español',    'ESP'),
    ('Uruguayo',   'URY'),
    ('Chileno',    'CHL'),
    ('Venezolano', 'VEN');

INSERT INTO ciudades (nombre, id_pais) VALUES
    ('Bogotá',       (SELECT id_pais FROM paises WHERE codigo_iso = 'COL')),
    ('Medellín',     (SELECT id_pais FROM paises WHERE codigo_iso = 'COL')),
    ('Cali',         (SELECT id_pais FROM paises WHERE codigo_iso = 'COL')),
    ('Barranquilla', (SELECT id_pais FROM paises WHERE codigo_iso = 'COL')),
    ('Buenos Aires', (SELECT id_pais FROM paises WHERE codigo_iso = 'ARG')),
    ('Rosario',      (SELECT id_pais FROM paises WHERE codigo_iso = 'ARG')),
    ('São Paulo',    (SELECT id_pais FROM paises WHERE codigo_iso = 'BRA')),
    ('Madrid',       (SELECT id_pais FROM paises WHERE codigo_iso = 'ESP'));

INSERT INTO posiciones (nombre, descripcion) VALUES
    ('Portero',                 'Guardameta, última línea defensiva'),
    ('Defensa Central',         'Defensor central del bloque'),
    ('Lateral Derecho',         'Defensor por la banda derecha'),
    ('Lateral Izquierdo',       'Defensor por la banda izquierda'),
    ('Mediocampista Defensivo', 'Volante de contención'),
    ('Mediocampista Ofensivo',  'Volante creador de juego'),
    ('Extremo Derecho',         'Atacante por la banda derecha'),
    ('Extremo Izquierdo',       'Atacante por la banda izquierda'),
    ('Delantero Centro',        'Punta de ataque'),
    ('Segundo Delantero',       'Atacante de apoyo');

INSERT INTO entrenadores (nombre, apellido, id_nacionalidad) VALUES
    ('Néstor',    'Lorenzo',    (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG')),
    ('Reinaldo',  'Rueda',      (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL')),
    ('Jorge',     'Sampaoli',   (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG')),
    ('Hernán',    'Crespo',     (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG')),
    ('Alexandre', 'Guimarães',  (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'BRA')),
    ('Julio',     'Comesaña',   (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'URY'));

-- =============================================================
--  TORNEOS
-- =============================================================

INSERT INTO torneos (nombre, fecha_inicio, fecha_fin, descripcion) VALUES
    ('Liga Apertura 2025', '2025-01-15', '2025-06-30', 'Torneo apertura de la primera división'),
    ('Copa Nacional 2026', '2026-03-01', '2026-08-31', 'Copa eliminatoria nacional 2026');

-- =============================================================
--  EQUIPOS
-- =============================================================

INSERT INTO equipos (nombre, id_ciudad, fecha_fundacion, id_entrenador) VALUES
    ('Atlético Nacional',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Medellín'),
        '1947-03-07',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Guimarães')),
    ('Deportivo Independiente Medellín',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Medellín'),
        '1913-05-12',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Crespo')),
    ('Millonarios FC',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Bogotá'),
        '1946-06-18',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Sampaoli')),
    ('América de Cali',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Cali'),
        '1927-02-13',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Rueda')),
    ('Junior FC',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Barranquilla'),
        '1924-08-01',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Comesaña')),
    ('Deportivo Cali',
        (SELECT id_ciudad FROM ciudades WHERE nombre = 'Cali'),
        '1912-09-14',
        (SELECT id_entrenador FROM entrenadores WHERE apellido = 'Lorenzo'));

-- =============================================================
--  ÁRBITROS
-- =============================================================

INSERT INTO arbitros (nombre, apellido, id_nacionalidad) VALUES
    ('Wilmar',   'Roldán',  (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL')),
    ('Andrés',   'Rojas',   (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL')),
    ('Néstor',   'Pitana',  (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG')),
    ('Patricio', 'Loustau', (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG'));

-- =============================================================
--  JUGADORES
-- =============================================================

-- Atlético Nacional
INSERT INTO jugadores (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nacimiento) VALUES
    ('Kevin',    'Mier',     (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Portero'),                  1, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1999-06-14'),
    ('Álvaro',   'Angulo',   (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Lateral Izquierdo'),        3, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1998-03-22'),
    ('Andrés',   'Román',    (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Defensa Central'),          4, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1996-11-05'),
    ('Jhon',     'Duque',    (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Mediocampista Defensivo'), 5, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1997-08-30'),
    ('Jefferson','Duque',    (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Delantero Centro'),         9, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1988-03-15'),
    ('Jarlan',   'Barrera',  (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Extremo Derecho'),         11, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1994-07-25');

-- Deportivo Independiente Medellín
INSERT INTO jugadores (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nacimiento) VALUES
    ('David',   'González',  (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Portero'),                  1, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1990-04-10'),
    ('Víctor',  'Moreno',    (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Defensa Central'),          4, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1994-09-18'),
    ('Andrés',  'Ricaurte',  (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Mediocampista Ofensivo'),   8, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1994-01-05'),
    ('Luciano', 'Pons',      (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Delantero Centro'),         9, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG'),  '1996-10-22'),
    ('Adrián',  'Arregui',   (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Mediocampista Defensivo'),  6, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'ARG'),  '1995-05-14');

-- Millonarios FC
INSERT INTO jugadores (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nacimiento) VALUES
    ('Álvaro',   'Montero',    (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Portero'),                  1, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1995-02-12'),
    ('Andrés',   'Llinás',     (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Defensa Central'),          3, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '2000-07-08'),
    ('David',    'Mackalister',(SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Mediocampista Ofensivo'),  10, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1989-11-23'),
    ('Leonardo', 'Castro',     (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Delantero Centro'),         9, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1988-06-26'),
    ('Daniel',   'Ruiz',       (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Extremo Izquierdo'),        7, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '2001-03-17');

-- América de Cali
INSERT INTO jugadores (nombre, apellido, id_equipo, id_posicion, numero_camiseta, id_nacionalidad, fecha_nacimiento) VALUES
    ('Joel',    'Graterol',  (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Portero'),                  1, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'VEN'), '1996-08-19'),
    ('Carlos',  'Sierra',    (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Lateral Derecho'),          2, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1998-12-03'),
    ('Adrián',  'Ramos',     (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Delantero Centro'),         9, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1986-01-22'),
    ('Rodrigo', 'Ureña',     (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Mediocampista Defensivo'),  5, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'CHL'), '1993-04-09'),
    ('Duván',   'Vergara',   (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali'), (SELECT id_posicion FROM posiciones WHERE nombre = 'Extremo Derecho'),         11, (SELECT id_nacionalidad FROM nacionalidades WHERE codigo_iso = 'COL'), '1997-06-28');

-- =============================================================
--  INSCRIBIR EQUIPOS EN TORNEOS — via SP
--  CALL no acepta subqueries, se usan bloques DO con variables.
-- =============================================================

DO $$
DECLARE
    v_liga   INT;
    v_copa   INT;
    v_nac    INT;
    v_dim    INT;
    v_millo  INT;
    v_america INT;
    v_junior INT;
    v_dcali  INT;
BEGIN
    SELECT id_torneo INTO v_liga  FROM torneos WHERE nombre = 'Liga Apertura 2025';
    SELECT id_torneo INTO v_copa  FROM torneos WHERE nombre = 'Copa Nacional 2026';
    SELECT id_equipo INTO v_nac   FROM equipos WHERE nombre = 'Atlético Nacional';
    SELECT id_equipo INTO v_dim   FROM equipos WHERE nombre = 'Deportivo Independiente Medellín';
    SELECT id_equipo INTO v_millo FROM equipos WHERE nombre = 'Millonarios FC';
    SELECT id_equipo INTO v_america FROM equipos WHERE nombre = 'América de Cali';
    SELECT id_equipo INTO v_junior FROM equipos WHERE nombre = 'Junior FC';
    SELECT id_equipo INTO v_dcali FROM equipos WHERE nombre = 'Deportivo Cali';

    -- Liga Apertura 2025
    CALL inscribir_equipo_torneo(v_liga, v_nac);
    CALL inscribir_equipo_torneo(v_liga, v_dim);
    CALL inscribir_equipo_torneo(v_liga, v_millo);
    CALL inscribir_equipo_torneo(v_liga, v_america);

    -- Copa Nacional 2026
    CALL inscribir_equipo_torneo(v_copa, v_nac);
    CALL inscribir_equipo_torneo(v_copa, v_millo);
    CALL inscribir_equipo_torneo(v_copa, v_junior);
    CALL inscribir_equipo_torneo(v_copa, v_dcali);
END $$;

-- =============================================================
--  PARTIDOS
--  El trigger trg_validar_fecha_partido rechaza automáticamente
--  cualquier partido fuera del rango del torneo.
-- =============================================================

-- Liga Apertura 2025 (rango: 2025-01-15 a 2025-06-30)
INSERT INTO partidos (id_torneo, id_equipo_local, id_equipo_visitante, id_arbitro, fecha_partido) VALUES
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Liga Apertura 2025'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Atlético Nacional'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Millonarios FC'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Roldán'),
        '2025-02-08 15:30:00'
    ),
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Liga Apertura 2025'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Deportivo Independiente Medellín'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'América de Cali'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Rojas'),
        '2025-02-09 17:00:00'
    ),
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Liga Apertura 2025'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Millonarios FC'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'América de Cali'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Pitana'),
        '2025-03-01 16:00:00'
    ),
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Liga Apertura 2025'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Atlético Nacional'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Deportivo Independiente Medellín'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Loustau'),
        '2025-03-15 19:00:00'
    );

-- Copa Nacional 2026 (rango: 2026-03-01 a 2026-08-31)
INSERT INTO partidos (id_torneo, id_equipo_local, id_equipo_visitante, id_arbitro, fecha_partido) VALUES
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Copa Nacional 2026'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Junior FC'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Atlético Nacional'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Roldán'),
        '2026-03-20 20:00:00'
    ),
    (
        (SELECT id_torneo FROM torneos  WHERE nombre   = 'Copa Nacional 2026'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Millonarios FC'),
        (SELECT id_equipo FROM equipos  WHERE nombre   = 'Deportivo Cali'),
        (SELECT id_arbitro FROM arbitros WHERE apellido = 'Rojas'),
        '2026-03-22 18:00:00'
    );

-- =============================================================
--  REGISTRAR RESULTADOS — via SP
--  Actualiza puntos, estadísticas y marca jugado = TRUE.
--  El trigger trg_recalcular_diferencia_goles se dispara
--  automáticamente al actualizar tabla_posiciones.
-- =============================================================

DO $$
DECLARE
    v_partido_1 INT;
    v_partido_2 INT;
    v_partido_3 INT;
BEGIN
    -- Nacional 2-1 Millonarios
    SELECT id_partido INTO v_partido_1
    FROM partidos
    WHERE id_equipo_local    = (SELECT id_equipo FROM equipos WHERE nombre = 'Atlético Nacional')
      AND id_equipo_visitante = (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC');

    -- DIM 0-0 América
    SELECT id_partido INTO v_partido_2
    FROM partidos
    WHERE id_equipo_local    = (SELECT id_equipo FROM equipos WHERE nombre = 'Deportivo Independiente Medellín')
      AND id_equipo_visitante = (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali');

    -- Millonarios 1-3 América
    SELECT id_partido INTO v_partido_3
    FROM partidos
    WHERE id_equipo_local    = (SELECT id_equipo FROM equipos WHERE nombre = 'Millonarios FC')
      AND id_equipo_visitante = (SELECT id_equipo FROM equipos WHERE nombre = 'América de Cali');

    CALL registrar_resultado(v_partido_1, 2, 1);
    CALL registrar_resultado(v_partido_2, 0, 0);
    CALL registrar_resultado(v_partido_3, 1, 3);
END $$;
