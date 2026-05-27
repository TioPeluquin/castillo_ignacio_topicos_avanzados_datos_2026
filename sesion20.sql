-- SESION 20 - REPASO Y PRUEBA 2
-- Actividad práctica: integrar tablas, vistas, procedimientos, triggers y consultas analíticas

-- 1) Crear tabla de resumen VIP a partir de Clientes y Pedidos
CREATE TABLE ClientesVIP (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    TotalGastado NUMBER,
    FechaRegistro DATE DEFAULT SYSDATE
);
/
-- 2) Vista de resumen por cliente (total y cantidad de pedidos)
CREATE OR REPLACE VIEW v_resumen_clientes AS
SELECT c.ClienteID,
       c.Nombre,
       c.Ciudad,
       NVL(COUNT(p.PedidoID),0) AS CantidadPedidos,
       NVL(SUM(p.Total),0) AS TotalGastado
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.ClienteID, c.Nombre, c.Ciudad;
/
-- 3) Función para calcular gasto de un cliente
CREATE OR REPLACE FUNCTION calcular_gasto_cliente(p_cliente_id IN NUMBER)
RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(Total),0) INTO v_total FROM Pedidos WHERE ClienteID = p_cliente_id;
    RETURN v_total;
END;
/
-- 4) Procedimiento para insertar/actualizar ClientesVIP según umbral
CREATE OR REPLACE PROCEDURE actualizar_clientes_vip(p_umbral IN NUMBER DEFAULT 1000) AS
BEGIN
    FOR r IN (
        SELECT ClienteID, Nombre, Ciudad, NVL(SUM(Total),0) AS TotalGastado
        FROM Clientes c
        LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY ClienteID, Nombre, Ciudad
        HAVING NVL(SUM(Total),0) >= p_umbral
    ) LOOP
        MERGE INTO ClientesVIP tgt
        USING (SELECT r.ClienteID AS ClienteID, r.Nombre AS Nombre, r.Ciudad AS Ciudad, r.TotalGastado AS TotalGastado FROM DUAL) src
        ON (tgt.ClienteID = src.ClienteID)
        WHEN MATCHED THEN UPDATE SET tgt.TotalGastado = src.TotalGastado
        WHEN NOT MATCHED THEN INSERT (ClienteID, Nombre, Ciudad, TotalGastado) VALUES (src.ClienteID, src.Nombre, src.Ciudad, src.TotalGastado);
    END LOOP;
    COMMIT;
END;
/
-- 5) Trigger: después de insertar un pedido, actualizar la vista/materializado y recalcular VIP si corresponde
CREATE OR REPLACE TRIGGER trg_post_insert_pedido
AFTER INSERT ON Pedidos
FOR EACH ROW
DECLARE
    v_new_total NUMBER;
BEGIN
    -- recalcular gasto del cliente que recibió el nuevo pedido
    v_new_total := calcular_gasto_cliente(:NEW.ClienteID);
    -- actualizar la tabla ClientesVIP si supera  el umbral de 1000 (umbral configurable en el procedimiento)
    IF v_new_total >= 1000 THEN
        BEGIN
            MERGE INTO ClientesVIP tgt
            USING (SELECT :NEW.ClienteID AS ClienteID, (SELECT Nombre FROM Clientes WHERE ClienteID = :NEW.ClienteID) AS Nombre,
                          (SELECT Ciudad FROM Clientes WHERE ClienteID = :NEW.ClienteID) AS Ciudad, v_new_total AS TotalGastado FROM DUAL) src
            ON (tgt.ClienteID = src.ClienteID)
            WHEN MATCHED THEN UPDATE SET tgt.TotalGastado = src.TotalGastado
            WHEN NOT MATCHED THEN INSERT (ClienteID, Nombre, Ciudad, TotalGastado) VALUES (src.ClienteID, src.Nombre, src.Ciudad, src.TotalGastado);
        END;
    END IF;
END;
/
-- 6) Materialized view: top 5 clientes por gasto (se puede refrescar manualmente)
CREATE MATERIALIZED VIEW mv_top_clientes
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
AS
SELECT * FROM (
    SELECT c.ClienteID, c.Nombre, NVL(SUM(p.Total),0) AS TotalGastado,
           RANK() OVER (ORDER BY NVL(SUM(p.Total),0) DESC) AS Rnk
    FROM Clientes c
    LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
    GROUP BY c.ClienteID, c.Nombre
) WHERE Rnk <= 5;
/
-- 7) Bloque de prueba: insertar un pedido de prueba, actualizar VIP y consultar resultados
DECLARE
    v_test_cliente NUMBER := 1; -- ajustar según datos existentes
BEGIN
    -- Insertar pedido de prueba
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido) VALUES (9999, v_test_cliente, 1200, SYSDATE);
    COMMIT;

    -- Ejecutar actualización de VIP
    actualizar_clientes_vip(1000);

    -- Consultas de verificación
    DBMS_OUTPUT.PUT_LINE('--- Resumen cliente (vista) ---');
    FOR r IN (SELECT * FROM v_resumen_clientes WHERE ClienteID = v_test_cliente) LOOP
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || r.Nombre || ' | TotalGastado: ' || r.TotalGastado || ' | Pedidos: ' || r.CantidadPedidos);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- ClientesVIP ---');
    FOR v IN (SELECT * FROM ClientesVIP WHERE ClienteID = v_test_cliente) LOOP
        DBMS_OUTPUT.PUT_LINE('VIP: ' || v.Nombre || ' | TotalGastado: ' || v.TotalGastado);
    END LOOP;

    -- Opcional: limpiar datos de prueba
    DELETE FROM Pedidos WHERE PedidoID = 9999;
    COMMIT;
END;
/
-- Fin SESION 20 - Repaso y Prueba 2
