-- ============================================================
-- Seguridad_Hospital.sql
-- Roles y permisos
-- ============================================================

CREATE ROLE admin_hospital LOGIN PASSWORD 'adminpass';
CREATE ROLE medico       NOINHERIT;
CREATE ROLE enfermera    NOINHERIT;
CREATE ROLE recepcionista NOINHERIT;
CREATE ROLE paciente     NOINHERIT;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA hospital TO admin_hospital;
GRANT SELECT, INSERT ON consultas, prescripciones TO medico;
GRANT SELECT ON pacientes, hospitalizaciones, habitaciones TO enfermera;
GRANT SELECT, INSERT ON pacientes, consultas TO recepcionista;
GRANT SELECT ON vista_paciente TO paciente;

ALTER TABLE consultas ENABLE ROW LEVEL SECURITY;

CREATE POLICY policia_medico_consultas
ON consultas
FOR SELECT
TO medico
USING (id_medico = current_setting('app.current_medico')::INT);
