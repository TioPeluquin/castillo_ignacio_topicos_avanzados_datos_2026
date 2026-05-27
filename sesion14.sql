-- SESION 14
-- EJERCICIO PRÁCTICO - SESIÓN 14 (HERENCIA)

CREATE OR REPLACE TYPE persona_obj AS OBJECT (
    persona_id NUMBER,
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY persona_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Persona ID: ' || persona_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
    END;
END;
/

CREATE OR REPLACE TYPE cliente_persona_obj UNDER persona_obj (
    monto_total NUMBER,
    MEMBER FUNCTION get_cliente_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_persona_obj AS
    MEMBER FUNCTION get_cliente_info RETURN VARCHAR2 IS
    BEGIN
        RETURN get_info() || ', Total Gastos: ' || monto_total;
    END;
END;
/

CREATE OR REPLACE TYPE empleado_obj UNDER persona_obj (
    departamento VARCHAR2(50),
    salario NUMBER,
    MEMBER FUNCTION get_empleado_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY empleado_obj AS
    MEMBER FUNCTION get_empleado_info RETURN VARCHAR2 IS
    BEGIN
        RETURN get_info() || ', Departamento: ' || departamento || ', Salario: ' || salario;
    END;
END;
/
CREATE TABLE personas_obj OF persona_obj (
    persona_id PRIMARY KEY
);

INSERT INTO personas_obj VALUES (cliente_persona_obj(10, 'Sofía Pérez', 'Concepción', 950));
INSERT INTO personas_obj VALUES (empleado_obj(20, 'Andrés Fuentes', 'Santiago', 'Ventas', 850000));

COMMIT;

SELECT p.persona_id,
       p.nombre,
       p.ciudad,
       CASE 
           WHEN VALUE(p) IS OF (cliente_persona_obj) THEN 'Cliente'
           WHEN VALUE(p) IS OF (empleado_obj) THEN 'Empleado'
           ELSE 'Persona'
       END AS Tipo,
       TREAT(VALUE(p) AS cliente_persona_obj).monto_total AS MontoTotal,
       TREAT(VALUE(p) AS empleado_obj).departamento AS Departamento,
       TREAT(VALUE(p) AS empleado_obj).salario AS Salario
FROM personas_obj p;

SELECT VALUE(p).get_info() AS InfoBase
FROM personas_obj p;

SELECT TREAT(VALUE(p) AS cliente_persona_obj).get_cliente_info() AS InfoCliente
FROM personas_obj p
WHERE VALUE(p) IS OF (cliente_persona_obj);

SELECT TREAT(VALUE(p) AS empleado_obj).get_empleado_info() AS InfoEmpleado
FROM personas_obj p
WHERE VALUE(p) IS OF (empleado_obj);
