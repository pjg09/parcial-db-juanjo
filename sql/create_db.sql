-- =============================================================
--  Base de datos: Gestión de Torneos
--  Motor: PostgreSQL
-- =============================================================

-- Crear y conectar a la base de datos
-- Ejecutar primero como superusuario:
--   CREATE DATABASE torneos_db;
--   \c torneos_db

-- =============================================================
--  TABLAS CATÁLOGO
-- =============================================================

CREATE TABLE paises (
    id_pais     SERIAL          PRIMARY KEY,
    nombre      VARCHAR(100)    NOT NULL,
    codigo_iso  CHAR(3)         NOT NULL,
    CONSTRAINT uq_pais_nombre       UNIQUE (nombre),
    CONSTRAINT uq_pais_codigo_iso   UNIQUE (codigo_iso)
);

CREATE TABLE ciudades (
    id_ciudad   SERIAL          PRIMARY KEY,
    nombre      VARCHAR(100)    NOT NULL,
    id_pais     INT             NOT NULL,
    CONSTRAINT fk_ciudad_pais   FOREIGN KEY (id_pais) REFERENCES paises (id_pais),
    CONSTRAINT uq_ciudad_pais   UNIQUE (nombre, id_pais)
);

CREATE TABLE nacionalidades (
    id_nacionalidad SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    codigo_iso      CHAR(3)         NOT NULL,
    CONSTRAINT uq_nac_nombre        UNIQUE (nombre),
    CONSTRAINT uq_nac_codigo_iso    UNIQUE (codigo_iso)
);

CREATE TABLE entrenadores (
    id_entrenador   SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    id_nacionalidad INT,
    CONSTRAINT fk_entrenador_nac    FOREIGN KEY (id_nacionalidad) REFERENCES nacionalidades (id_nacionalidad)
);

CREATE TABLE posiciones (
    id_posicion SERIAL          PRIMARY KEY,
    nombre      VARCHAR(50)     NOT NULL,
    descripcion VARCHAR(150),
    CONSTRAINT uq_posicion_nombre   UNIQUE (nombre)
);

-- =============================================================
--  TABLAS PRINCIPALES
-- =============================================================

CREATE TABLE torneos (
    id_torneo       SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE            NOT NULL,
    descripcion     VARCHAR(255),
    CONSTRAINT uq_torneo_nombre     UNIQUE (nombre),
    CONSTRAINT chk_fechas_torneo    CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE equipos (
    id_equipo       SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    id_ciudad       INT             NOT NULL,
    fecha_fundacion DATE,
    id_entrenador   INT,
    CONSTRAINT uq_equipo_nombre     UNIQUE (nombre),
    CONSTRAINT fk_equipo_ciudad     FOREIGN KEY (id_ciudad)     REFERENCES ciudades     (id_ciudad),
    CONSTRAINT fk_equipo_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenadores (id_entrenador)
);

CREATE TABLE jugadores (
    id_jugador      SERIAL          PRIMARY KEY,
    id_equipo       INT             NOT NULL,
    id_nacionalidad INT,
    id_posicion     INT             NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    numero_camiseta INT             NOT NULL,
    fecha_nacimiento DATE,
    CONSTRAINT fk_jugador_equipo    FOREIGN KEY (id_equipo)       REFERENCES equipos       (id_equipo),
    CONSTRAINT fk_jugador_nac       FOREIGN KEY (id_nacionalidad) REFERENCES nacionalidades (id_nacionalidad),
    CONSTRAINT fk_jugador_posicion  FOREIGN KEY (id_posicion)     REFERENCES posiciones    (id_posicion),
    CONSTRAINT chk_numero_camiseta  CHECK (numero_camiseta BETWEEN 1 AND 99),
    CONSTRAINT uq_camiseta_equipo   UNIQUE (id_equipo, numero_camiseta)
);

CREATE TABLE arbitros (
    id_arbitro      SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    id_nacionalidad INT,
    CONSTRAINT fk_arbitro_nac   FOREIGN KEY (id_nacionalidad) REFERENCES nacionalidades (id_nacionalidad)
);

CREATE TABLE partidos (
    id_partido          SERIAL      PRIMARY KEY,
    id_torneo           INT         NOT NULL,
    id_equipo_local     INT         NOT NULL,
    id_equipo_visitante INT         NOT NULL,
    id_arbitro          INT,
    fecha_partido       TIMESTAMP   NOT NULL,
    goles_local         INT         NOT NULL DEFAULT 0,
    goles_visitante     INT         NOT NULL DEFAULT 0,
    jugado              BOOLEAN     NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_partido_torneo        FOREIGN KEY (id_torneo)           REFERENCES torneos  (id_torneo),
    CONSTRAINT fk_partido_local         FOREIGN KEY (id_equipo_local)     REFERENCES equipos  (id_equipo),
    CONSTRAINT fk_partido_visitante     FOREIGN KEY (id_equipo_visitante) REFERENCES equipos  (id_equipo),
    CONSTRAINT fk_partido_arbitro       FOREIGN KEY (id_arbitro)          REFERENCES arbitros (id_arbitro),
    CONSTRAINT chk_equipos_distintos    CHECK (id_equipo_local <> id_equipo_visitante),
    CONSTRAINT chk_goles_local          CHECK (goles_local >= 0),
    CONSTRAINT chk_goles_visitante      CHECK (goles_visitante >= 0)
);

CREATE TABLE tabla_posiciones (
    id_tabla            SERIAL  PRIMARY KEY,
    id_torneo           INT     NOT NULL,
    id_equipo           INT     NOT NULL,
    puntos              INT     NOT NULL DEFAULT 0,
    partidos_jugados    INT     NOT NULL DEFAULT 0,
    partidos_ganados    INT     NOT NULL DEFAULT 0,
    partidos_empatados  INT     NOT NULL DEFAULT 0,
    partidos_perdidos   INT     NOT NULL DEFAULT 0,
    goles_favor         INT     NOT NULL DEFAULT 0,
    goles_contra        INT     NOT NULL DEFAULT 0,
    diferencia_goles    INT     NOT NULL DEFAULT 0,
    CONSTRAINT fk_tabla_torneo      FOREIGN KEY (id_torneo) REFERENCES torneos (id_torneo),
    CONSTRAINT fk_tabla_equipo      FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo),
    CONSTRAINT uq_equipo_torneo     UNIQUE (id_torneo, id_equipo),
    CONSTRAINT chk_puntos_positivos CHECK (puntos >= 0)
);

-- =============================================================
--  ÍNDICES
-- =============================================================

CREATE INDEX idx_jugadores_equipo    ON jugadores         (id_equipo);
CREATE INDEX idx_jugadores_posicion  ON jugadores         (id_posicion);
CREATE INDEX idx_partidos_torneo     ON partidos          (id_torneo);
CREATE INDEX idx_partidos_fecha      ON partidos          (fecha_partido);
CREATE INDEX idx_tabla_torneo        ON tabla_posiciones  (id_torneo);

-- =============================================================
--  STORED PROCEDURES
-- =============================================================

-- SP1: Inscribir un equipo en un torneo
CREATE OR REPLACE PROCEDURE inscribir_equipo_torneo(
    p_id_torneo INT,
    p_id_equipo INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM tabla_posiciones
        WHERE id_torneo = p_id_torneo AND id_equipo = p_id_equipo
    ) THEN
        RAISE EXCEPTION 'El equipo % ya está inscrito en el torneo %.', p_id_equipo, p_id_torneo;
    END IF;

    INSERT INTO tabla_posiciones (id_torneo, id_equipo)
    VALUES (p_id_torneo, p_id_equipo);
END;
$$;

-- SP2: Registrar el resultado de un partido
CREATE OR REPLACE PROCEDURE registrar_resultado(
    p_id_partido        INT,
    p_goles_local       INT,
    p_goles_visitante   INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_id_torneo           INT;
    v_id_equipo_local     INT;
    v_id_equipo_visitante INT;
    v_puntos_local        INT;
    v_puntos_visitante    INT;
BEGIN
    -- Obtener datos del partido
    SELECT id_torneo, id_equipo_local, id_equipo_visitante
    INTO v_id_torneo, v_id_equipo_local, v_id_equipo_visitante
    FROM partidos
    WHERE id_partido = p_id_partido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe el partido con id %.', p_id_partido;
    END IF;

    -- Determinar puntos según resultado
    IF p_goles_local > p_goles_visitante THEN
        v_puntos_local      := 3;
        v_puntos_visitante  := 0;
    ELSIF p_goles_local < p_goles_visitante THEN
        v_puntos_local      := 0;
        v_puntos_visitante  := 3;
    ELSE
        v_puntos_local      := 1;
        v_puntos_visitante  := 1;
    END IF;

    -- Actualizar resultado en partidos
    UPDATE partidos
    SET goles_local       = p_goles_local,
        goles_visitante   = p_goles_visitante,
        jugado            = TRUE
    WHERE id_partido = p_id_partido;

    -- Actualizar tabla de posiciones: equipo local
    UPDATE tabla_posiciones
    SET puntos              = puntos + v_puntos_local,
        partidos_jugados    = partidos_jugados + 1,
        partidos_ganados    = partidos_ganados + CASE WHEN v_puntos_local = 3 THEN 1 ELSE 0 END,
        partidos_empatados  = partidos_empatados + CASE WHEN v_puntos_local = 1 THEN 1 ELSE 0 END,
        partidos_perdidos   = partidos_perdidos + CASE WHEN v_puntos_local = 0 THEN 1 ELSE 0 END,
        goles_favor         = goles_favor + p_goles_local,
        goles_contra        = goles_contra + p_goles_visitante
    WHERE id_torneo = v_id_torneo AND id_equipo = v_id_equipo_local;

    -- Actualizar tabla de posiciones: equipo visitante
    UPDATE tabla_posiciones
    SET puntos              = puntos + v_puntos_visitante,
        partidos_jugados    = partidos_jugados + 1,
        partidos_ganados    = partidos_ganados + CASE WHEN v_puntos_visitante = 3 THEN 1 ELSE 0 END,
        partidos_empatados  = partidos_empatados + CASE WHEN v_puntos_visitante = 1 THEN 1 ELSE 0 END,
        partidos_perdidos   = partidos_perdidos + CASE WHEN v_puntos_visitante = 0 THEN 1 ELSE 0 END,
        goles_favor         = goles_favor + p_goles_visitante,
        goles_contra        = goles_contra + p_goles_local
    WHERE id_torneo = v_id_torneo AND id_equipo = v_id_equipo_visitante;
END;
$$;

-- =============================================================
--  TRIGGERS
-- =============================================================

-- TRG1: Validar que la fecha del partido esté dentro del rango del torneo
CREATE OR REPLACE FUNCTION fn_validar_fecha_partido()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_fecha_inicio DATE;
    v_fecha_fin    DATE;
BEGIN
    SELECT fecha_inicio, fecha_fin
    INTO v_fecha_inicio, v_fecha_fin
    FROM torneos
    WHERE id_torneo = NEW.id_torneo;

    IF NEW.fecha_partido::DATE < v_fecha_inicio OR NEW.fecha_partido::DATE > v_fecha_fin THEN
        RAISE EXCEPTION
            'La fecha del partido (%) está fuera del rango del torneo (% – %).',
            NEW.fecha_partido::DATE, v_fecha_inicio, v_fecha_fin;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_fecha_partido
BEFORE INSERT OR UPDATE ON partidos
FOR EACH ROW EXECUTE FUNCTION fn_validar_fecha_partido();

-- TRG2: Recalcular diferencia de goles automáticamente al actualizar tabla_posiciones
CREATE OR REPLACE FUNCTION fn_recalcular_diferencia_goles()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.diferencia_goles := NEW.goles_favor - NEW.goles_contra;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_recalcular_diferencia_goles
BEFORE UPDATE ON tabla_posiciones
FOR EACH ROW EXECUTE FUNCTION fn_recalcular_diferencia_goles();
