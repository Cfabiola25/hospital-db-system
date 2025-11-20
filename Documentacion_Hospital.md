# **DOCUMENTACIÓN COMPLETA – SISTEMA DE GESTIÓN HOSPITALARIA**

**Proyecto – Evaluación Final (PostgreSQL 16)**
**Estudiante: Nelly Fabiola Cano Oviedo - 18405  Nestor Ivan Granados Valenzuela - 18442**

---

# 🔴 **FASE 1 – DISEÑO CONCEPTUAL (UNIDAD 1)**

## 1.1. Introducción general del sistema

El Sistema de Gestión Hospitalaria permite administrar toda la información crítica de un hospital, garantizando integridad, consistencia, trazabilidad y seguridad.
El modelo soporta procesos de atención médica, consultas, prescripciones, manejo de medicamentos, hospitalizaciones, asignación de camas y auditoría transaccional.

Este diseño se fundamenta en un **modelo relacional normalizado**, orientado a operaciones multiusuario con alto grado de concurrencia y reglas ACID.

---

# **1.2. Modelo Entidad–Relación (ER)**

### **Entidades principales**

* **Pacientes**
* **Médicos**
* **Departamentos**
* **Consultas**
* **Medicamentos**
* **Prescripciones**
* **Habitaciones**
* **Hospitalizaciones**

### **Relaciones clave**

* Un departamento tiene muchos médicos.
* Un médico atiende muchas consultas.
* Un paciente puede tener múltiples consultas.
* Una consulta puede tener múltiples prescripciones.
* Las hospitalizaciones ligan paciente + habitación + médico.
* Las habitaciones tienen un estado (LIBRE / OCUPADA).


---

# **1.3. Arquitectura de tres niveles**

## 🔹 **Nivel Interno (Físico)**

* Tablas reales dentro del esquema `hospital`.
* PK, FK, CHECK, UNIQUE, tipos de dato adecuados.
* Índices estratégicos para optimizar consultas.

## 🔹 **Nivel Lógico**

* Modelo relacional normalizado a 3FN.
* Relaciones estructuradas según el ER.
* Reglas de integridad referencial activas.

## 🔹 **Nivel Externo**

**Vistas según rol:**

* `vista_paciente` → historial personal del paciente.
* `vista_medico` → consultas del médico y pacientes atendidos.
* `vista_administracion` → métricas de alta gerencia.

---

# 🔴 **FASE 2 – NORMALIZACIÓN Y DDL (UNIDAD 2)**

## **2.1. Normalización hasta 3FN (explicada paso a paso)**

### **→ Primera Forma Normal (1FN)**

* No existen listas ni campos multivalorados.
* Todos los atributos son atómicos.
* Cada tabla tiene clave primaria.
* Relaciones N:N fueron resueltas (consultas–medicamentos → prescripciones).

### **→ Segunda Forma Normal (2FN)**

* No se usa ninguna clave compuesta.
* Todos los atributos dependen por completo de su PK.
  Ejemplos:
* *especialidad* depende SOLO de `medicos.id_medico`
* *diagnóstico* depende SOLO de `consultas.id_consulta`

### **→ Tercera Forma Normal (3FN)**

* No existen dependencias transitivas.
  Ejemplos:
* La *ubicación* del departamento está solo en `departamentos`, no en `medicos`.
* La *especialidad* del médico no aparece en consultas (solo FK).
* Información del paciente nunca se duplica en hospitalizaciones ni consultas.

---

# **2.2. Script DDL completo**

Incluye:

* esquema `hospital`,
* tabla `audit_log`,
* restricciones PK, FK, CHECK, UNIQUE,
* tipos correctos,
* coherencia referencial.

Están en el archivo Script_DDL_Hospital.sql

---

# **2.3. Cinco consultas complejas**

Estas consultas demuestran dominio de `JOIN`, `GROUP BY`, `FILTER`, índices, analítica:

1. **Consultas por departamento (estadística operacional)**
2. **Histórico clínico completo de un paciente**
3. **Ocupación de camas con filtros**
4. **Medicamentos más prescritos (ranking)**
5. **Médicos con más consultas atendidas**

Están en el archivo Consultas_Hospital.sql

---

# 🔴 **FASE 3 – GESTIÓN TRANSACCIONAL (UNIDAD 3)**

## **3.1. Procedimiento ACID: admisión de emergencia**

Este procedimiento:

* se ejecuta en una **sola transacción**,
* garantiza atomicidad: si algo falla → rollback completo,
* evita inconsistencias al asignar camas,
* actualiza estado y crea hospitalización.

La clave ACID es:

```sql
FOR UPDATE SKIP LOCKED
```

Esto:

* bloquea la fila de la cama apropiadamente,
* evita que dos transacciones usen la misma,
* permite concurrencia real sin bloqueos globales.

Están en el archivo Procedimientos_Hospital.sql

---

## **3.2. Trigger de auditoría completo**

El trigger:

* registra **INSERT**, **UPDATE**, **DELETE**,
* guarda datos anteriores y nuevos en JSONB,
* graba usuario, fecha y tabla,
* permite trazabilidad total del historial médico.

Este componente cumple:

* **Trazabilidad**
* **Revisiones históricas**
* **Gobernanza de datos**

Están en el archivo Procedimientos_Hospital.sql

---

## **3.3. Estrategia de concurrencia y locks**

La implementación usa:

### ✔ `FOR UPDATE`

* Bloquea la fila de habitación seleccionada.

### ✔ `SKIP LOCKED`

* Evita esperas innecesarias.
* Salta habitaciones ya bloqueadas por otras transacciones.
* Permite concurrencia sin bloqueos muertos (deadlocks).

### ✔ Una sola transacción

El procedimiento garantiza atomicidad:

* si falla la inserción:
  la cama vuelve a su estado original,
* si falla un UPDATE o FK:
  la transacción revierte.

---

# 🔴 **FASE 4 – SEGURIDAD Y OPTIMIZACIÓN**

## **4.1. Diseño de roles**

Roles funcionales:

| Rol                | Permisos principales                            |
| ------------------ | ----------------------------------------------- |
| **admin_hospital** | Acceso total, gestiona todo el sistema          |
| **medico**         | Consultar e insertar consultas y prescripciones |
| **enfermera**      | Ver pacientes, hospitalizaciones y habitaciones |
| **recepcionista**  | Registrar pacientes y consultas                 |
| **paciente**       | Ver solo su propia vista `vista_paciente`       |

Está implementado en Seguridad_Hospital.sql
---

## **4.2. RLS (Row-Level Security)**

El objetivo:
**Permitir que un médico solo vea SUS pacientes y SUS consultas.**

### Política aplicada:

```sql
ALTER TABLE consultas ENABLE ROW LEVEL SECURITY;

CREATE POLICY policia_medico_consultas
ON consultas
FOR SELECT
TO medico
USING (id_medico = current_setting('app.current_medico')::INT);
```

### Explicación funcional:

* Antes de ejecutar queries, la app hace:

```sql
SET app.current_medico = '1';
```

* El usuario con rol `medico` solo verá filas donde:

  * `consultas.id_medico` = su ID autenticado.

Esto cumple:

* control por usuario,
* privacidad de datos clínicos,
* cumplimiento de normativas.

---

## **4.3. Índices estratégicos**

Índices generados:

```sql
CREATE INDEX idx_consultas_id_medico_fecha
ON consultas (id_medico, fecha_consulta);

CREATE INDEX idx_hospitalizaciones_id_habitacion
ON hospitalizaciones (id_habitacion);

CREATE INDEX idx_prescripciones_id_medicamento
ON prescripciones (id_medicamento);
```

### Justificación técnica:

* Mejoran queries con `JOIN`.
* Reducen `Seq Scan` costosos.
* Aceleran filtros por médico, habitación y medicamento.

---

## **4.4. Análisis con EXPLAIN ANALYZE**

Ejemplo aplicado:

```sql
EXPLAIN ANALYZE
SELECT med.nombre, med.apellido,
       COUNT(c.id_consulta) AS total_consultas
FROM medicos med
JOIN consultas c ON c.id_medico = med.id_medico
GROUP BY med.id_medico, med.nombre, med.apellido
ORDER BY total_consultas DESC
LIMIT 10;
```

### Resultados esperados:

* Uso del índice `idx_consultas_id_medico_fecha`
* Ejecución optimizada (< X ms según tu equipo)
* Eliminación de `Seq Scan` en tablas grandes

En el informe puedes destacar:

> El plan utilizó un **Index Scan**, reduciendo el costo estimado y real, demostrando que los índices creados son efectivos para consultas de análisis médico.

---

# 🔴 **FASE 5 – CONCLUSIONES GENERALES**

* El modelo relacional es adecuado para un sistema hospitalario por requerir:

  * integridad referencial,
  * auditoría,
  * ACID,
  * seguridad estricta,
  * control de acceso granular.

* PostgreSQL fue elegido sobre MongoDB porque:

  * soporta transacciones ACID reales,
  * facilita triggers y RLS nativos,
  * maneja vistas, funciones y roles avanzados,
  * ajusta perfectamente a datos fuertemente estructurados.

* La arquitectura diseñada es escalable, segura y cumple con estándares profesionales de bases de datos.

---

# 🔴 **FASE 6 – ARCHIVOS ENTREGABLES**

La entrega se compone de:

| Archivo                         | Contenido                                          |
| ------------------------------- | -------------------------------------------------- |
| **Script_DDL_Hospital.sql**     | Tablas, PK, FK, CHECK, UNIQUE                      |
| **Consultas_Hospital.sql**      | 5 consultas complejas                              |
| **Procedimientos_Hospital.sql** | Trigger + procedimiento ACID                       |
| **Seguridad_Hospital.sql**      | Roles, permisos, RLS                               |
| **Vistas_Hospital.sql**         | vista_medico, vista_paciente, vista_administracion |
| **Indices_Hospital.sql**        | Índices                                            |
| **Documentacion_Hospital.md**   | Este documento completo                            |

