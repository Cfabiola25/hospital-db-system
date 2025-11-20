-- ============================================================
-- Vistas_Hospital.sql
-- ============================================================

CREATE OR REPLACE VIEW vista_paciente AS
SELECT 
    p.id_paciente,
    p.nombre AS nombre_paciente,
    p.apellido AS apellido_paciente,
    c.id_consulta,
    c.fecha_consulta,
    c.motivo,
    c.diagnostico,
    m.nombre AS nombre_medico,
    m.apellido AS apellido_medico
FROM pacientes p
LEFT JOIN consultas c ON c.id_paciente = p.id_paciente
LEFT JOIN medicos m ON m.id_medico = c.id_medico;

CREATE OR REPLACE VIEW vista_medico AS
SELECT
    m.id_medico,
    m.nombre AS nombre_medico,
    m.apellido AS apellido_medico,
    c.id_consulta,
    c.fecha_consulta,
    c.motivo,
    c.diagnostico,
    p.nombre AS nombre_paciente,
    p.apellido AS apellido_paciente
FROM medicos m
LEFT JOIN consultas c ON c.id_medico = m.id_medico
LEFT JOIN pacientes p ON p.id_paciente = c.id_paciente;

CREATE OR REPLACE VIEW vista_administracion AS
SELECT 
    d.nombre_departamento,
    COUNT(c.id_consulta) AS total_consultas,
    COUNT(h.id_hospitalizacion) AS total_hospitalizaciones,
    COUNT(DISTINCT p.id_paciente) AS pacientes_unicos
FROM departamentos d
LEFT JOIN medicos m ON m.id_departamento = d.id_departamento
LEFT JOIN consultas c ON c.id_medico = m.id_medico
LEFT JOIN hospitalizaciones h ON h.id_medico = m.id_medico
LEFT JOIN pacientes p ON p.id_paciente = c.id_paciente
GROUP BY d.nombre_departamento;
