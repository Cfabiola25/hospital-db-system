-- ============================================================
-- Indices_Hospital.sql
-- ============================================================

CREATE INDEX idx_consultas_id_medico_fecha
ON consultas (id_medico, fecha_consulta);

CREATE INDEX idx_hospitalizaciones_id_habitacion
ON hospitalizaciones (id_habitacion);

CREATE INDEX idx_prescripciones_id_medicamento
ON prescripciones (id_medicamento);
