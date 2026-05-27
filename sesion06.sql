-- SESION 6
-- OBJETOS DE BASES DE DATOS - SESIÓN 6

CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || cliente_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
    END;
END;
/

-- Crear Tabla Basada en Objetos

CREATE TABLE clientes_obj OF cliente_obj (
    cliente_id PRIMARY KEY
);

-- Insertar datos en tabla de objetos
INSERT INTO clientes_obj VALUES (1, 'Juan Perez', 'Santiago');
INSERT INTO clientes_obj VALUES (2, 'María Gomez', 'Valparaiso');
INSERT INTO clientes_obj VALUES (3, 'Ana Lopez', 'Santiago');

COMMIT;

-- EJERCICIOS PRÁCTICOS - SESIÓN 6 (OBJETOS)

DECLARE
    -- Cursor que selecciona objetos de tipo cliente_obj
    CURSOR cliente_obj_cursor IS
        SELECT VALUE(c) AS cliente
        FROM clientes_obj c
        ORDER BY c.nombre ASC;
    
    -- Variable para almacenar el objeto
    v_cliente cliente_obj;
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 1: Cursor Basado en Objeto ===');
    DBMS_OUTPUT.PUT_LINE('Listado de Clientes (Nombre - Ciudad):');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    
    -- Abrir cursor
    OPEN cliente_obj_cursor;
    
    -- Procesar filas
    LOOP
        FETCH cliente_obj_cursor INTO v_cliente;
        
        EXIT WHEN cliente_obj_cursor%NOTFOUND;
        
        v_contador := v_contador + 1;
        
        -- Acceder a atributos del objeto
        DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || v_cliente.nombre || ' - ' || v_cliente.ciudad);
        
        -- Llamar a método del objeto
        DBMS_OUTPUT.PUT_LINE('   Info Completa: ' || v_cliente.get_info());
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de clientes: ' || v_contador);
    
    -- Cerrar cursor
    CLOSE cliente_obj_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF cliente_obj_cursor%ISOPEN THEN
            CLOSE cliente_obj_cursor;
        END IF;
END;
/

-- PRÁCTICA 2: Cursor Explícito con Parámetro Basado en Objeto


DECLARE
    -- Cursor parametrizado basado en objeto
    CURSOR cliente_obj_param_cursor(p_ciudad VARCHAR2) IS
        SELECT VALUE(c) AS cliente
        FROM clientes_obj c
        WHERE c.ciudad = p_ciudad
        FOR UPDATE;
    
    -- Variables para almacenar datos
    v_cliente cliente_obj;
    v_ciudad_param VARCHAR2(50) := 'Santiago';
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 2: Cursor Parametrizado de Objetos ===');
    DBMS_OUTPUT.PUT_LINE('Procesando clientes de: ' || v_ciudad_param);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    
    -- Abrir cursor con parámetro
    OPEN cliente_obj_param_cursor(v_ciudad_param);
    
    LOOP
        FETCH cliente_obj_param_cursor INTO v_cliente;
        
        EXIT WHEN cliente_obj_param_cursor%NOTFOUND;
        
        v_contador := v_contador + 1;
        
        DBMS_OUTPUT.PUT_LINE('Registro ' || v_contador || ':');
        DBMS_OUTPUT.PUT_LINE('  Información del Objeto: ' || v_cliente.get_info());
        DBMS_OUTPUT.PUT_LINE('  ID: ' || v_cliente.cliente_id);
        DBMS_OUTPUT.PUT_LINE('  Nombre: ' || v_cliente.nombre);
        DBMS_OUTPUT.PUT_LINE('  Ciudad: ' || v_cliente.ciudad);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de clientes procesados en ' || v_ciudad_param || ': ' || v_contador);
    
    -- Cerrar cursor
    CLOSE cliente_obj_param_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF cliente_obj_param_cursor%ISOPEN THEN
            CLOSE cliente_obj_param_cursor;
        END IF;
END;
/
