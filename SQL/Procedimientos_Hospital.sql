-- ============================================================
-- Procedimientos_Hospital.sql
-- Triggers y procedimientos transaccionales
-- ============================================================

SET search_path TO hospital;

-- PROCEDIMIENTO: admisión de emergencia
CREATE OR REPLACE FUNCTION admision_emergencia(
    p_id_paciente INT,
    p_id_medico   INT,
    p_motivo      TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_habitacion INT;
BEGIN
    SELECT id_habitacion
    INTO v_id_habitacion
    FROM habitaciones
    WHERE estado = 'LIBRE'
    FOR UPDATE SKIP LOCKED
    LIMIT 1;

    IF v_id_habitacion IS NULL THEN
        RAISE EXCEPTION 'No hay habitaciones disponibles';
    END IF;

    UPDATE habitaciones
    SET estado = 'OCUPADA'
    WHERE id_habitacion = v_id_habitacion;

    INSERT INTO hospitalizaciones (
        id_paciente, id_habitacion, id_medico, motivo_ingreso, fecha_ingreso
    ) VALUES (
        p_id_paciente, v_id_habitacion, p_id_medico, p_motivo, NOW()
    );
END;
$$;

-- TRIGGER DE AUDITORÍA
CREATE OR REPLACE FUNCTION fn_audit_consultas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log(tabla, operacion, id_registro, datos_nuevos)
        VALUES ('consultas', 'INSERT', NEW.id_consulta, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log(tabla, operacion, id_registro, datos_anteriores, datos_nuevos)
        VALUES ('consultas', 'UPDATE', NEW.id_consulta, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log(tabla, operacion, id_registro, datos_anteriores)
        VALUES ('consultas', 'DELETE', OLD.id_consulta, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_consultas
AFTER INSERT OR UPDATE OR DELETE
ON consultas
FOR EACH ROW
EXECUTE FUNCTION fn_audit_consultas();
