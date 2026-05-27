-- SESION 12
-- EJERCICIOS PRÁCTICOS - SESIÓN 12

-- 1. Función que calcula el total con 10% de descuento si supera 1000
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) 
RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT Total INTO v_total FROM Pedidos WHERE PedidoID = p_pedido_id;
    
    IF v_total > 1000 THEN
        v_total := v_total * 0.9; -- Aplicar 10%[cite: 6]
    END IF;
    
    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');[cite: 6]
END;
/

-- 2. Procedimiento que aplica el descuento usando la función anterior[cite: 6]
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) AS
    v_nuevo_total NUMBER;
BEGIN
    v_nuevo_total := calcular_total_con_descuento(p_pedido_id);
    
    UPDATE Pedidos SET Total = v_nuevo_total WHERE PedidoID = p_pedido_id;
    
    DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id || ' actualizado a: ' || v_nuevo_total);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/
--EJERCICIO PRACTICO 2
CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    -- Uso de :NEW para validar el valor entrante[cite: 6]
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');[cite: 6]
    END IF;
END;
/
