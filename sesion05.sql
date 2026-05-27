-- SESION 5
-- EJERCICIOS PRÁCTICOS - SESIÓN 5 (CURSORES EXPLÍCITOS)

DECLARE
    -- Declarar cursor explícito que lista 2 atributos
    CURSOR cliente_cursor IS
        SELECT Nombre, Ciudad
        FROM Clientes
        ORDER BY Nombre ASC;
    
    -- Variables para almacenar los datos del cursor
    v_nombre VARCHAR2(50);
    v_ciudad VARCHAR2(50);
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 1: Listado de Clientes con Cursor ===');
    DBMS_OUTPUT.PUT_LINE('Formato: Nombre - Ciudad');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    
    -- Abrir el cursor
    OPEN cliente_cursor;
    
    -- Procesar filas una por una
    LOOP
        FETCH cliente_cursor INTO v_nombre, v_ciudad;
        
        -- Condición para salir del bucle cuando no hay más filas
        EXIT WHEN cliente_cursor%NOTFOUND;
        
        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || v_nombre || ' - ' || v_ciudad);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de clientes: ' || v_contador);
    
    -- Cerrar el cursor
    CLOSE cliente_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF cliente_cursor%ISOPEN THEN
            CLOSE cliente_cursor;
        END IF;
END;
/

-- PRÁCTICA 2: Cursor Explícito con Parámetro y FOR UPDATE


DECLARE
    -- Cursor explícito CON PARÁMETRO
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
    
    -- Variables para almacenar datos
    v_pedido_id NUMBER;
    v_total_original NUMBER;
    v_total_nuevo NUMBER;
    v_cliente_id NUMBER := 1; -- Parámetro: Cliente con ID 1
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 2: Actualización de Pedidos con Cursor Parametrizado ===');
    DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || v_cliente_id);
    DBMS_OUTPUT.PUT_LINE('Incremento: 10%');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    
    -- Abrir cursor pasando el parámetro
    OPEN pedido_cursor(v_cliente_id);
    
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total_original;
        
        EXIT WHEN pedido_cursor%NOTFOUND;
        
        -- Calcular nuevo total (10% de incremento)
        v_total_nuevo := v_total_original * 1.10;
        
        v_contador := v_contador + 1;
        
        -- Mostrar valor ORIGINAL
        DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ':');
        DBMS_OUTPUT.PUT_LINE('  Valor Original: ' || v_total_original);
        
        -- Actualizar el pedido usando WHERE CURRENT OF
        UPDATE Pedidos
        SET Total = v_total_nuevo
        WHERE CURRENT OF pedido_cursor;
        
        -- Mostrar valor ACTUALIZADO
        DBMS_OUTPUT.PUT_LINE('  Valor Actualizado: ' || v_total_nuevo);
        DBMS_OUTPUT.PUT_LINE('  Aumento: ' || (v_total_nuevo - v_total_original));
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de pedidos actualizados: ' || v_contador);
    
    -- Cerrar cursor
    CLOSE pedido_cursor;
    
    -- Confirmar cambios
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF pedido_cursor%ISOPEN THEN
            CLOSE pedido_cursor;
        END IF;
        ROLLBACK;
END;
/
