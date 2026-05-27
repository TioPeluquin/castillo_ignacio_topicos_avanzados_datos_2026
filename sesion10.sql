-- SESION 10
-- EJERCICIOS PRÁCTICOS - SESIÓN 10 (PROCEDIMIENTOS ALMACENADOS AVANZADOS)

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(
    p_cliente_id IN NUMBER, 
    p_porcentaje IN NUMBER DEFAULT 10
) AS
    -- Cursor para iterar sobre los pedidos del cliente con bloqueo de filas
    CURSOR pedido_cursor IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
BEGIN
    -- Uso de bucle FOR para recorrer el cursor
    FOR pedido IN pedido_cursor LOOP
        UPDATE Pedidos
        SET Total = pedido.Total * (1 + p_porcentaje / 100)
        WHERE CURRENT OF pedido_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
    END LOOP;

    -- Verificar si se realizaron cambios[cite: 4]
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El cliente ' || p_cliente_id || ' no tiene pedidos para actualizar.');
    ELSE
        COMMIT; -- Confirmar cambios si hubo éxito[cite: 4]
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error[cite: 4]
END;
/
--EJERCICIO PRACTICO 2
CREATE OR REPLACE PROCEDURE calcular_costo_detalle(
    p_detalle_id IN NUMBER, 
    p_costo IN OUT NUMBER
) AS
    v_precio NUMBER;
    v_cantidad NUMBER;
BEGIN
    -- JOIN entre DetallesPedidos y Productos para obtener los valores[cite: 4]
    SELECT p.Precio, d.Cantidad 
    INTO v_precio, v_cantidad
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;

    p_costo := v_precio * v_cantidad;
    DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id || ': ' || p_costo);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');[cite: 4]
END;
/

-- Prueba del Ejercicio 2[cite: 4]
DECLARE
    v_costo_resultado NUMBER := 0;
BEGIN
    calcular_costo_detalle(1, v_costo_resultado);
    DBMS_OUTPUT.PUT_LINE('Valor final en variable: ' || v_costo_resultado);
END;
/
-- Prueba del Ejercicio 1[cite: 4]
EXEC actualizar_total_pedidos(1);
