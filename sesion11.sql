-- SESION 11
-- EJERCICIOS PRÁCTICOS - SESIÓN 11 (FUNCIONES ALMACENADAS)

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) 
RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    -- Cálculo de años entre la fecha actual y el nacimiento
    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');[cite: 5]
END;
/

-- Prueba del Ejercicio 1
SELECT Nombre, calcular_edad_cliente(ClienteID) AS Edad FROM Clientes;
--EJERCICIO PRÁCTICO 2
CREATE OR REPLACE FUNCTION obtener_precio_promedio 
RETURN NUMBER AS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_promedio FROM Productos;
    RETURN v_promedio;
END;
/

-- Prueba del Ejercicio 2: Listar productos por encima del promedio[cite: 5]
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();
