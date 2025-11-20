-- ============================================================
-- Consultas_Hospital.sql
-- Consultas complejas del sistema hospitalario
-- ============================================================

-- 1. Estadísticas de consultas por departamento
SELECT d.nombre_departamento,
       COUNT(c.id_consulta) AS total_consultas
FROM departamentos d
JOIN medicos m ON m.id_departamento = d.id_departamento
JOIN consultas c ON c.id_medico = m.id_medico
GROUP BY d.nombre_departamento
ORDER BY total_consultas DESC;

-- 2. Histórico de consultas de un paciente
SELECT p.nombre, p.apellido,
       c.fecha_consulta, c.motivo, c.diagnostico
FROM pacientes p
JOIN consultas c ON c.id_paciente = p.id_paciente
WHERE p.documento = '123456789'
ORDER BY c.fecha_consulta DESC;

-- 3. Ocupación de camas
SELECT 
    COUNT(*) FILTER (WHERE estado = 'OCUPADA') AS camas_ocupadas,
    COUNT(*) FILTER (WHERE estado = 'LIBRE')  AS camas_libres,
    COUNT(*) AS total_camas
FROM habitaciones;

-- 4. Medicamentos más prescritos
SELECT m.nombre_medicamento,
       COUNT(pres.id_prescripcion) AS veces_prescrito
FROM medicamentos m
JOIN prescripciones pres ON pres.id_medicamento = m.id_medicamento
GROUP BY m.nombre_medicamento
ORDER BY veces_prescrito DESC
LIMIT 10;

-- 5. Médicos con más consultas
SELECT med.nombre, med.apellido,
       COUNT(c.id_consulta) AS total_consultas
FROM medicos med
JOIN consultas c ON c.id_medico = med.id_medico
GROUP BY med.id_medico, med.nombre, med.apellido
ORDER BY total_consultas DESC
LIMIT 10;

