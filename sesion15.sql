-- SESION 15
-- EJERCICIO PRÁCTICO - SESIÓN 15 (PAQUETES PL/SQL)

CREATE OR REPLACE PACKAGE pkg_pedidos AS
    PROCEDURE registrar_pedido(
        p_pedido_id NUMBER,
        p_cliente_id NUMBER,
        p_total NUMBER,
        p_fecha_pedido DATE
    );

    FUNCTION total_pedidos_cliente(p_cliente_id NUMBER) RETURN NUMBER;

    PROCEDURE mostrar_resumen_cliente(p_cliente_id NUMBER);
END pkg_pedidos;
/

CREATE OR REPLACE PACKAGE BODY pkg_pedidos AS
    PROCEDURE registrar_pedido(
        p_pedido_id NUMBER,
        p_cliente_id NUMBER,
        p_total NUMBER,
        p_fecha_pedido DATE
    ) IS
    BEGIN
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
        VALUES (p_pedido_id, p_cliente_id, p_total, p_fecha_pedido);

        DBMS_OUTPUT.PUT_LINE('Pedido registrado: ' || p_pedido_id || ' para cliente ' || p_cliente_id);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: El pedido ' || p_pedido_id || ' ya existe.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR al registrar pedido: ' || SQLERRM);
    END registrar_pedido;

    FUNCTION total_pedidos_cliente(p_cliente_id NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id;

        RETURN NVL(v_total, 0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR al contar pedidos: ' || SQLERRM);
            RETURN 0;
    END total_pedidos_cliente;

    PROCEDURE mostrar_resumen_cliente(p_cliente_id NUMBER) IS
        v_nombre VARCHAR2(50);
        v_total_gastado NUMBER;
    BEGIN
        SELECT Nombre INTO v_nombre FROM Clientes WHERE ClienteID = p_cliente_id;
        SELECT NVL(SUM(Total), 0) INTO v_total_gastado FROM Pedidos WHERE ClienteID = p_cliente_id;

        DBMS_OUTPUT.PUT_LINE('Resumen cliente ' || p_cliente_id || ': ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Total de pedidos: ' || total_pedidos_cliente(p_cliente_id));
        DBMS_OUTPUT.PUT_LINE('Total gastado: ' || v_total_gastado);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Cliente ' || p_cliente_id || ' no existe.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR al mostrar resumen: ' || SQLERRM);
    END mostrar_resumen_cliente;
END pkg_pedidos;
/

BEGIN
    pkg_pedidos.registrar_pedido(105, 4, 550, TO_DATE('2025-03-05', 'YYYY-MM-DD'));
    pkg_pedidos.registrar_pedido(106, 2, 410, TO_DATE('2025-03-06', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Total pedidos cliente 4: ' || pkg_pedidos.total_pedidos_cliente(4));
    pkg_pedidos.mostrar_resumen_cliente(4);
END;
/
