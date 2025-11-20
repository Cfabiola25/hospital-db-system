-- ============================================================
-- Script_DDL_Hospital.sql
-- Base de datos del Sistema de Gestión Hospitalaria
-- Esquema completo en 3FN
-- ============================================================

CREATE SCHEMA IF NOT EXISTS hospital;
SET search_path TO hospital;

-- =======================
-- TABLA: departamentos
-- =======================
CREATE TABLE departamentos (
    id_departamento SERIAL PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(100)
);

-- =======================
-- TABLA: medicos
-- =======================
CREATE TABLE medicos (
    id_medico SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    id_departamento INT NOT NULL REFERENCES departamentos(id_departamento),
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

-- =======================
-- TABLA: pacientes
-- =======================
CREATE TABLE pacientes (
    id_paciente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(10) NOT NULL,
    documento VARCHAR(30) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(150),
    sexo CHAR(1) CHECK (sexo IN ('M','F')),
    grupo_sanguineo VARCHAR(5)
);

-- =======================
-- TABLA: consultas
-- =======================
CREATE TABLE consultas (
    id_consulta SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL REFERENCES pacientes(id_paciente),
    id_medico INT NOT NULL REFERENCES medicos(id_medico),
    fecha_consulta DATE NOT NULL,
    hora_consulta TIME NOT NULL,
    motivo TEXT,
    diagnostico TEXT
);

-- =======================
-- TABLA: medicamentos
-- =======================
CREATE TABLE medicamentos (
    id_medicamento SERIAL PRIMARY KEY,
    nombre_medicamento VARCHAR(100) NOT NULL,
    descripcion TEXT,
    presentacion VARCHAR(100)
);

-- =======================
-- TABLA: prescripciones
-- =======================
CREATE TABLE prescripciones (
    id_prescripcion SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL REFERENCES consultas(id_consulta),
    id_medicamento INT NOT NULL REFERENCES medicamentos(id_medicamento),
    dosis VARCHAR(50),
    frecuencia VARCHAR(50),
    duracion_dias INT
);

-- =======================
-- TABLA: habitaciones
-- =======================
CREATE TABLE habitaciones (
    id_habitacion SERIAL PRIMARY KEY,
    numero_habitacion VARCHAR(10) NOT NULL UNIQUE,
    tipo_habitacion VARCHAR(50),
    estado VARCHAR(10) NOT NULL CHECK (estado IN ('LIBRE','OCUPADA'))
);

-- =======================
-- TABLA: hospitalizaciones
-- =======================
CREATE TABLE hospitalizaciones (
    id_hospitalizacion SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL REFERENCES pacientes(id_paciente),
    id_habitacion INT NOT NULL REFERENCES habitaciones(id_habitacion),
    id_medico INT NOT NULL REFERENCES medicos(id_medico),
    fecha_ingreso TIMESTAMP DEFAULT NOW(),
    fecha_egreso TIMESTAMP,
    motivo_ingreso TEXT
);

-- =======================
-- TABLA: audit_log
-- =======================
CREATE TABLE audit_log (
    id_audit SERIAL PRIMARY KEY,
    tabla VARCHAR(50) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    id_registro INTEGER,
    usuario_bd TEXT DEFAULT current_user,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos_anteriores JSONB,
    datos_nuevos JSONB
);
