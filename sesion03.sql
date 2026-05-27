-- SESION 3
-- EJERCICIO PRÁCTICO - SESIÓN 3

DECLARE
    -- Variables para almacenar datos del cliente y su clasificación
    v_cliente_id NUMBER := 1;
    v_nombre_cliente VARCHAR2(50);
    v_total_gastos NUMBER;
    v_categoria VARCHAR2(20);
    v_mensaje_categoria VARCHAR2(200);
    
BEGIN
    -- Obtener el nombre del cliente
    SELECT Nombre INTO v_nombre_cliente
    FROM Clientes
    WHERE ClienteID = v_cliente_id;
    
    -- Calcular el total de gastos del cliente
    SELECT COALESCE(SUM(Total), 0) INTO v_total_gastos
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;
    
    -- Clasificar según los criterios documentados
    IF v_total_gastos >= 600 THEN
        v_categoria := 'ALTO';
        v_mensaje_categoria := 'Cliente VIP con alto volumen de compras';
    ELSIF v_total_gastos >= 300 THEN
        v_categoria := 'MEDIO';
        v_mensaje_categoria := 'Cliente con compras moderadas y potencial de crecimiento';
    ELSE
        v_categoria := 'BAJO';
        v_mensaje_categoria := 'Cliente con compras limitadas - Aplicar estrategia de retención';
    END IF;
    
    -- Mostrar resultados
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('REPORTE DE CLASIFICACIÓN DE CLIENTE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || v_cliente_id);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('Total Gastos: ' || v_total_gastos);
    DBMS_OUTPUT.PUT_LINE('Categoría: ' || v_categoria);
    DBMS_OUTPUT.PUT_LINE('Descripción: ' || v_mensaje_categoria);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Cliente ' || v_cliente_id || ' no encontrado en la base de datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/
