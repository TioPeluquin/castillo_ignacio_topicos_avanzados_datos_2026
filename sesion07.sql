-- SESION 7
-- EJERCICIOS PRÁCTICOS - SESIÓN 7 (PROCEDIMIENTOS ALMACENADOS)

CREATE OR REPLACE PROCEDURE aumentar_precio_producto (
    p_producto_id IN NUMBER, 
    p_porcentaje IN NUMBER
) AS
    v_precio_actual NUMBER;
BEGIN
    -- Intentar la actualización
    UPDATE Productos
    SET Precio = Precio + (Precio * p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    -- Si no se afectó ninguna fila, el producto no existe
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El producto con ID ' || p_producto_id || ' no existe en la base de datos.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Éxito: Precio del producto ' || p_producto_id || ' aumentado en un ' || p_porcentaje || '%.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error inesperado: ' || SQLERRM);
        ROLLBACK;
END;
/
-- PRACTICA 2 
-- Bloque de prueba para el Ejercicio 1
BEGIN
    -- Prueba con producto existente (ID 1)
    aumentar_precio_producto(1, 15); -- Aumenta 15%
    -- Prueba con producto inexistente
    aumentar_precio_producto(99, 10); 
END;
/
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente (
    p_cliente_id IN NUMBER, 
    p_cantidad OUT NUMBER
) AS
BEGIN
    -- Contar registros para el cliente dado
    SELECT COUNT(*) 
    INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;

    -- Si por alguna razón el resultado es nulo, asegurar que devuelva 0
    IF p_cantidad IS NULL THEN
        p_cantidad := 0;
    END IF;
END;
/

-- Bloque de prueba para el Ejercicio 2
DECLARE
    v_num_pedidos NUMBER;
    v_id_test NUMBER := 1;
BEGIN
    contar_pedidos_cliente(v_id_test, v_num_pedidos);
    DBMS_OUTPUT.PUT_LINE('El cliente con ID ' || v_id_test || ' tiene un total de ' || v_num_pedidos || ' pedidos.');
END;
/
