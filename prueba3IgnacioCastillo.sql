-- Script para crear y poblar la base de datos para la Prueba 3
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crear tabla Agentes
CREATE TABLE Agentes (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);

-- Crear tabla Incidentes
CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Crear tabla Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

-- Insertar datos en Agentes
INSERT INTO Agentes VALUES (101, 'Camila Reyes',     'Pentester',       TO_DATE('2023-03-15','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (102, 'Diego Muñoz',      'Analista SOC',    TO_DATE('2022-07-01','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (103, 'Valentina Soto',   'Analista SOC',    TO_DATE('2024-01-10','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (105, 'Francisca López',  'Pentester',       TO_DATE('2023-08-05','YYYY-MM-DD'));

-- Insertar datos en Incidentes
INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto',  TO_DATE('2026-03-01','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH',        'High',     'Abierto',  TO_DATE('2026-03-03','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional',            'High',     'Cerrado',  TO_DATE('2026-03-20','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos',               'Critical', 'Abierto',  TO_DATE('2026-04-05','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (205, 'Exfiltración de datos via DNS tunneling',     'Medium',   'Cerrado',  TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (206, 'Acceso no autorizado a base de datos',        'Critical', 'Abierto',  TO_DATE('2026-05-02','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (207, 'Malware en estaciones de trabajo',            'Medium',   'Cerrado',  TO_DATE('2026-05-15','YYYY-MM-DD'));

-- Insertar datos en Asignaciones
INSERT INTO Asignaciones VALUES (1,  101, 201, 40, 'Lider');
INSERT INTO Asignaciones VALUES (2,  102, 201, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (3,  102, 202, 20, 'Lider');
INSERT INTO Asignaciones VALUES (4,  103, 202, 25, 'Apoyo');
INSERT INTO Asignaciones VALUES (5,  103, 203, 30, 'Lider');
INSERT INTO Asignaciones VALUES (6,  104, 204, 45, 'Lider');
INSERT INTO Asignaciones VALUES (7,  101, 204, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (8,  105, 205, 25, 'Lider');
INSERT INTO Asignaciones VALUES (9,  104, 201, 20, 'Apoyo');
INSERT INTO Asignaciones VALUES (10, 102, 206, 50, 'Lider');
INSERT INTO Asignaciones VALUES (11, 105, 206, 30, 'Apoyo');
INSERT INTO Asignaciones VALUES (12, 103, 207, 15, 'Lider');

COMMIT;

SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;


--EJERCICIO 1 - PROCEDIMIENTO CON SAVEPOINTS Y VALIDACIONES


-- Procedimiento para registrar una asignación con validaciones y savepoints
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_agente_id    IN NUMBER,
    p_incidente_id IN NUMBER,
    p_horas        IN NUMBER,
    p_rol          IN VARCHAR2
) AS
    v_proximo_id       NUMBER;
    v_horas_agente     NUMBER;
    v_agentes_incidente NUMBER;
BEGIN
    SAVEPOINT sp_inicio;

    IF p_horas <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Horas inválidas. Deben ser mayores a cero.');
    END IF;

    SELECT NVL(MAX(AsignacionID), 0) + 1
      INTO v_proximo_id
      FROM Asignaciones;

    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_proximo_id, p_agente_id, p_incidente_id, p_horas, p_rol);
    SAVEPOINT sp_insert;

    SELECT NVL(SUM(a.Horas), 0)
      INTO v_horas_agente
      FROM Asignaciones a
      JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
     WHERE a.AgenteID = p_agente_id
       AND i.Estado = 'Abierto';

    IF v_horas_agente > 100 THEN
        ROLLBACK TO sp_inicio;
        RAISE_APPLICATION_ERROR(-20002, 'El agente supera 100 horas en incidentes Abiertos.');
    END IF;
    SAVEPOINT sp_validacion_horas;

    SELECT COUNT(*)
      INTO v_agentes_incidente
      FROM Asignaciones
     WHERE IncidenteID = p_incidente_id;

    IF v_agentes_incidente >= 3 THEN
        ROLLBACK TO sp_inicio;
        RAISE_APPLICATION_ERROR(-20003, 'El incidente ya tiene 3 o más agentes asignados.');
    END IF;
    SAVEPOINT sp_validacion_agentes;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Asignación registrada correctamente. ID=' || v_proximo_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO sp_inicio;
        RAISE_APPLICATION_ERROR(-20004, 'Agente o incidente no encontrado.');
    WHEN OTHERS THEN
        IF SQLCODE IN (-20001, -20002, -20003) THEN
            RAISE;
        ELSE
            ROLLBACK TO sp_inicio;
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado: ' || SQLERRM);
        END IF;
END registrar_asignacion;
/

-- Ejemplo de uso del procedimiento
BEGIN
    registrar_asignacion(105, 202, 20, 'Apoyo');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar la asignación: ' || SQLERRM);
END;
/

--EJERCICIO 2 - CREACIÓN DE TABLAS DIMENSIONALES Y DE HECHOS PARA DATA WAREHOUSE

-- Crear tabla de dimensión Dim_Agente
CREATE TABLE Dim_Agente (
    Agente_SK       NUMBER PRIMARY KEY,
    AgenteID        NUMBER,
    Nombre          VARCHAR2(50),
    Especialidad    VARCHAR2(50),
    FechaIngreso    DATE
);

-- Crear tabla de dimensión Dim_Incidente
CREATE TABLE Dim_Incidente (
    Incidente_SK    NUMBER PRIMARY KEY,
    IncidenteID     NUMBER,
    Descripcion     VARCHAR2(100),
    Severidad       VARCHAR2(20),
    Estado          VARCHAR2(20),
    FechaDeteccion  DATE
);

-- Crear tabla de hechos Fact_Asignaciones
CREATE TABLE Fact_Asignaciones (
    Hecho_SK        NUMBER PRIMARY KEY,
    Agente_SK       NUMBER,
    Incidente_SK    NUMBER,
    Horas           NUMBER,
    Rol             VARCHAR2(30),
    CONSTRAINT fk_fact_agente    FOREIGN KEY (Agente_SK)    REFERENCES Dim_Agente(Agente_SK),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (Incidente_SK) REFERENCES Dim_Incidente(Incidente_SK)
);

-- Poblar Dim_Agente
INSERT INTO Dim_Agente
SELECT ROWNUM, AgenteID, Nombre, Especialidad, FechaIngreso FROM Agentes;

-- Poblar Dim_Incidente
INSERT INTO Dim_Incidente
SELECT ROWNUM, IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion FROM Incidentes;

-- Poblar Fact_Asignaciones
INSERT INTO Fact_Asignaciones
SELECT ROWNUM, 
       (SELECT Agente_SK FROM Dim_Agente DA WHERE DA.AgenteID = A.AgenteID),
       (SELECT Incidente_SK FROM Dim_Incidente DI WHERE DI.IncidenteID = A.IncidenteID),
       A.Horas,
       A.Rol
FROM Asignaciones A;

COMMIT;

-- Consulta analítica sobre tablas transaccionales
-- Muestra para cada agente el total de horas y número de incidentes atendidos
SELECT 
    ag.AgenteID,
    ag.Nombre,
    SUM(a.Horas) AS Total_Horas,
    COUNT(DISTINCT a.IncidenteID) AS Num_Incidentes
FROM Agentes ag
LEFT JOIN Asignaciones a ON ag.AgenteID = a.AgenteID
GROUP BY ag.AgenteID, ag.Nombre
ORDER BY Total_Horas DESC;

-- Consulta analítica equivalente sobre el Data Warehouse
SELECT 
    da.AgenteID,
    da.Nombre,
    SUM(fa.Horas) AS Total_Horas,
    COUNT(DISTINCT fa.Incidente_SK) AS Num_Incidentes
FROM Dim_Agente da
LEFT JOIN Fact_Asignaciones fa ON da.Agente_SK = fa.Agente_SK
GROUP BY da.AgenteID, da.Nombre
ORDER BY Total_Horas DESC;

--EJERCICIO 3 - ÍNDICE COMPUESTO Y PARTICIÓN POR RANGO

-- Crear índice compuesto en Incidentes para Severidad y FechaDeteccion
CREATE INDEX idx_incidentes_sev_fec ON Incidentes(Severidad, FechaDeteccion);

-- Consulta que muestra el total de horas asignadas por incidente 
-- para incidentes 'Critical' detectados en Q1 2026
SELECT 
    i.IncidenteID,
    i.Descripcion,
    i.Severidad,
    i.FechaDeteccion,
    SUM(a.Horas) AS Total_Horas_Asignadas
FROM Incidentes i
LEFT JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') 
                           AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion, i.Severidad, i.FechaDeteccion
ORDER BY i.FechaDeteccion;

-- Ver el plan de ejecución de la consulta anterior
EXPLAIN PLAN FOR
SELECT 
    i.IncidenteID,
    i.Descripcion,
    i.Severidad,
    i.FechaDeteccion,
    SUM(a.Horas) AS Total_Horas_Asignadas
FROM Incidentes i
LEFT JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') 
                           AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion, i.Severidad, i.FechaDeteccion;

-- Mostrar el plan de ejecución
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================

INSTRUCCIONES GENERALES:
- Tiempo: 90 minutos
- Puntaje total: 100 puntos
- Parte 1 (teórica): 40 puntos | Parte 2 (práctica): 60 puntos
- Ejecute el script de datos antes de comenzar la parte práctica
- En la parte teórica, la lógica y el concepto son lo que se evalúa;
  errores menores de sintaxis no penalizan si la idea es correcta

================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================

PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

Una transacción es un conjunto de opracioones que se ejecutan como una sola unidad lógica.
La idea es que todas las operaciones dentro de la transacción deben completarse correctamente para que los cambios se confirmen en la base de datos.
Si alguna operación falla, toda la transacción debe revertirse para mantener la integridad de los datos.
PRINCIPIO ACID:

Atomicidad: una transacción se completa por completo o se deshace 0por completo.
Consistencia: deja la base de datos en un estado válido.
Aislamiento: las transacciones concurrentes no interfieren entre sí.
Durabilidad: si una transacción se confirma, sus cambios persisten aunque luego ocurra un fallo.

Si la actualización del estado falla, el procedimiento puede usar savepoints para revertir solo esa parte de la transacción, manteniendo las asignaciones previas intactas.

EJ:
Un procedimiento que realiza dos acciones en una misma operación:

insertar una nueva asignación de un agente a un incidente, y actualizar el estado del incidente para indicar que ya está siendo atendido.
Para manejar esto de forma segura, se usan varios savepoints:

Primero se crea un savepoint inicial, que marca el punto desde el cual se puede deshacer toda la operación si algo sale mal.
Luego, después de insertar la asignación, se crea otro savepoint. Esto significa que si la siguiente parte falla, se puede deshacer solo lo que pasó después de ese punto.
Después, se intenta actualizar el estado del incidente. Si esa actualización falla, se puede volver al savepoint anterior y conservar la asignación insertada.




PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

Un Data Warehouse es una base de datos orientada al análisis, diseñada para almacenar datos históricos y consolidados de diferentes fuentes. Su objetivo no es registrar 
operaciones diarias, sino permitir consultar información para reportes, KPIs y análisis de tendencias.

Una base de datos transaccional, en cambio, es la que usa la operación diaria del sistema. 
Está pensada para insertar, actualizar y borrar datos rápidamente, manteniendo integridad y consistencia en procesos.

Diferencias principales
Data Warehouse: lectura analítica, datos históricos, modelado para reportes.
Base transaccional: procesamiento operativo, datos actuales, alta concurrencia y normalización.

Modelo dimensional:
Para analizar horas trabajadas por agente y por severidad de incidente, lo mas adecuado es un modelo en estrella
con tablas de hechos y dimensiones.
Tabla de hechos: Fact_Asignaciones con claves de agente, incidente, tiempo y medida de horas
Dimensiones: Dim_Agente y Dim_Incidente
Dim_Agente: AgenteID, Nombre, Especialidad, FechaIngreso
Dim_Incidente: IncidenteID, Descripcion, Severidad, Estado, FechaDet
Se podría consultar:
total de horas por agente
total de horas por severidad
comparación entre agentes
evolución de horas por trimestre

Este modelo facilita mucho las consultas analíticas porque:

simplifica los joins entre tablas
permite agregar datos fácilmente con funciones como SUM, COUNT y GROUP BY
mejora el rendimiento para reportes
organiza la información de forma más intuitiva para análisis
permite filtrar por atributos como agente, severidad o fecha




PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

La herencia se implementa con tipos de objetos y subtipos. 
Se define un tipo base con atributos y métodos, y luego se crean subtipos que extienden
ese tipo base añadiendo atributos adicionales o redefiniendo métodos.

Agente (tipo base)
Atributos: AgenteID, Nombre, Especialidad
Método: calcular_costo() que devuelve un costo básico según horas o tarifa estándar.

AgenteEspecialista (subtipo de Agente)
Atributos adicionales: NivelEspecialidad, CostoHoraExtra
Método calcular_costo() sobreescrito para incluir un recargo por especialidad.

AgentePentester (subtipo de AgenteEspecialista)
Atributos adicionales: Certificaciones, TarifaPentesting
Método calcular_costo() sobreescrito otra vez para aplicar una tarifa específica de pentesting y sumar el costo de certificaciones o consultoría especializada.

Declarar un tipo como NOT INSTANTIABLE significa que no se pueden crear instancias directas de ese tipo. 
El tipo existe solo como clase base para subtipos.

Implicancias: No puedes hacer NEW Agente() si Agente es NOT INSTANTIABLE.
Solo puedes crear instancias de sus subtipos concretos, como AgenteEspecialista o AgentePentester.




PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

INDICES
Ventajas:
Aceleran búsquedas y filtros en columnas específicas.
Mejoran consultas WHERE, JOIN y ORDER BY.
Desventajas:
Ocupan espacio adicional.
Hacen más lentas las operaciones INSERT, UPDATE y DELETE, porque el índice también debe mantenerse.
No siempre ayudan si la consulta recupera muchos registros.

PARTICIONES
Ventajas:
Dividen una tabla grande en trozos más pequeños, lo que puede mejorar el rendimiento y la gestión.
Permiten archivar o borrar particiones completas fácilmente.
Reducen el trabajo de escaneo cuando la consulta solo necesita algunas particiones.
Desventajas:
Aumentan la complejidad del diseño y la administración.
No mejoran todas las consultas; solo las que usan la columna de partición.
Pueden requerir más planificación de mantenimiento.

Para consultas que filtran por Severidad y FechaDeteccion, conviene:
crear un índice compuesto sobre (Severidad, FechaDeteccion),
particionar la tabla Incidentes por rango de FechaDeteccion.

Así:
el índice compuesto ayuda cuando la consulta filtra ambas columnas.
la partición por rango de FechaDeteccion divide los datos por trimestres de 2026.

CREATE INDEX idx_incidentes_sev_fec ON Incidentes(Severidad, FechaDeteccion);
CREATE TABLE Incidentes (...) PARTITION BY RANGE (FechaDeteccion) (...)

Partition pruning es la capacidad del optimizador para descartar particiones que no pueden contener filas de la consulta.

Impacto en el plan de ejecución
Si la consulta filtra por FechaDeteccion dentro de un rango concreto, Oracle solo lee las particiones relevantes.
Esto reduce el número de bloques leídos y mejora el rendimiento.
En el plan de ejecución se ve que solo se accede a ciertas particiones, en vez de escanear toda la tabla.




================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.

EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.

EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

RESPUESTAS PRACTICAS ESTAN ARRIBA EN EL SCRIPT SQL ADJUNTO.

================================================================================
*/
