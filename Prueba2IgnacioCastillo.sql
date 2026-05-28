--1° Un procedimiento es una operación que puede devolver cero o varios valores por Out. No puede usarse directamente de una cnsulta
--Ej de uso es crear un procedimiento crear_asignacion que inserte una fila en Asignaciones, registre auditoría y devuelva un nuevo AsignacionID por parametro OUT
-- Una función devuelve un único valor con RETURN, suele usarse dentro de consultas SQL.
--EJ de uso es crear una función total_horas_incidentes que calcule la suma total de horas de Asignaciones para un IncidenteID y se use en un SELECT para listar totales.

--2° Cuando se requiere pasar un valor que va a ser modificado dentro del procedimiento, como ajustar las horas de una asignación y que devuelva el valor actualizado.
create or replace procedure ajustar_horas_asignacion (
    p_asignacion_id IN NUMBER,
    p_horas_ajustar IN NUMBER,
    p_horas_actualizadas OUT NUMBER
) AS
begin
    -- Actualizar las horas en la tabla Asignaciones
    UPDATE Asignaciones
    SET Horas = Horas + p_horas_ajustar
    WHERE AsignacionID = p_asignacion_id
    RETURNING Horas INTO p_horas_actualizadas; 

    COMMIT;
END;
/

--3°
CREATE OR REPLACE FUNCTION total_horas_incidentes (p_incidente_id IN NUMBER) RETURN NUMBER AS
    v_total_horas NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_total_horas  
    RETURN NVL(v_total_horas, 0);
END;
/
--  CONSULTA
SELECT i.IncidenteID, i.Descripcion, total_horas_incidentes(i.IncidenteID) AS TotalHoras    
FROM Incidentes i;

--4° El TRIGGER es un bloque de código PL/SQL que se ejecuta automáticamente en respuesta de eventos en la BD. Existen TRIGGERS a nivel fila y a nivel de sentencia.
-- Se pueden disparar mediante INSERT, UPDATE o DELETE en tablas, y en de base/DDL con LOGON, DDL o AFTER SERVERERROR

CREATE OR REPLACE TRIGGER trg_audit_asignaciones
AFTER INSERT ON Asignaciones
FOR EACH ROW
BEGIN 
    UPDATE Incidentes
    SET Estado = 'En Procreso'  
    WHERE IncidenteID = :NEW.IncidenteID AND Estado = 'Abierto';
END;
/


---------PARTE 2---------
--1°
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_agente_id IN NUMBER,
    p_incidente_id IN NUMBER,
    p_horas IN NUMBER,
    p_rol IN VARCHAR2
) AS
    v_estado Incidentes.Estado%TYPE;
    v_count NUMBER;
    v_next_id NUMBER;
BEGIN
    -- Verifica si el agente existe
    BEGIN 
    SELECT COUNT(*) INTO v_count FROM Agentes WHERE AgenteID = p_agente_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Agente no encontrado');
    END;

-- Verificar que el incidente existe y obtener su estado
    BEGIN
    SELECT Estado INTO v_estado FROM Incidentes WHERE IncidenteID = p_incidenteID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Incidente no existe: ' || p_incidenteID);
    END;

-- Comprobar si el agente ya está asignado a ese incidente
SELECT COUNT(*) INTO v_count FROM Asignaciones
    WHERE AgenteID = p_agenteID AND IncidenteID = p_incidenteID;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Agente ya asignado a este incidente');
    END IF;
    
-- Calcular próximo AsignacionID (si tienes una secuencia, úsala en su lugar)
SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_next_id FROM Asignaciones;

-- Insertar la nueva asignación
INSERT INTO Asignaciones(AsignacionID, AgenteID, IncidenteID, Horas, Rol)
VALUES (v_next_id, p_agenteID, p_incidenteID, p_horas, p_rol);

-- Actualizar estado del incidente si estaba 'Abierto'
IF UPPER(NVL(v_estado,' ')) = 'ABIERTO' THEN
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = p_incidenteID;
END IF;

COMMIT; 

DMB_OUTPUT.PUT_LINE('Asignación registrada exitosamente con ID: ' || v_next_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DMB_OUTPUT.PUT_LINE('Error al registrar asignación: ' || SQLERRM);
END;
/
--2° Función para calcular el total de horas asignadas a un agente.
CREATE OR REPLACE FUNCTION calcular_horas_agente(p_agenteID IN NUMBER) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(Horas), 0) INTO v_total
  FROM Asignaciones
  WHERE AgenteID = p_agenteID;

  RETURN v_total;
END calcular_horas_agente;
/
-- Procedimiento para mostrar el total de horas asignadas a un agente.
CREATE OR REPLACE PROCEDURE mostrar_carga_agentes IS
  CURSOR c_agentes IS
    SELECT AgenteID, Nombre, Especialidad FROM Agentes ORDER BY AgenteID;
  v_total NUMBER;
BEGIN
  FOR r IN c_agentes LOOP
    v_total := calcular_horas_agente(r.AgenteID);
    DBMS_OUTPUT.PUT_LINE(
      'Agente ' || r.AgenteID || ' - ' || r.Nombre || ' (' || r.Especialidad || '): ' || v_total || ' horas'
    );
  END LOOP;
END mostrar_carga_agentes;
/

SET SERVEROUTPUT ON SIZE 1000000
BEGIN
  mostrar_carga_agentes;
END;
/       


--3° Triggers 
-- Tabla de auditoría
CREATE TABLE AuditoriaAsignaciones (
  AuditID       NUMBER PRIMARY KEY,
  AsignacionID  NUMBER,
  AgenteID      NUMBER,
  IncidenteID   NUMBER,
  Horas         NUMBER,
  Accion        VARCHAR2(10),
  FechaRegistro DATE
);

-- Trigger de auditoría
CREATE OR REPLACE TRIGGER audit_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
  INSERT INTO AuditoriaAsignaciones (
    AuditID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro
  ) VALUES (
    aud_asignaciones_seq.NEXTVAL,
    NVL(:NEW.AsignacionID, :OLD.AsignacionID),
    NVL(:NEW.AgenteID, :OLD.AgenteID),
    NVL(:NEW.IncidenteID, :OLD.IncidenteID),
    NVL(:NEW.Horas, :OLD.Horas),
    CASE
      WHEN INSERTING THEN 'INSERT'
      WHEN DELETING THEN 'DELETE'
      ELSE 'OTHER'
    END,
    SYSDATE
  );
END;
/










