-- SESION 17
-- EJERCICIO PRÁCTICO - SESIÓN 17 (VISTAS MATERIALIZADAS Y FUNCIONES ANALÍTICAS)

CREATE MATERIALIZED VIEW mv_ventas_por_ciudad
REFRESH FAST ON DEMAND
AS
SELECT c.Ciudad,
       COUNT(p.PedidoID) AS TotalPedidos,
       SUM(p.Total) AS TotalVentas,
       AVG(p.Total) AS PromedioVenta
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Ciudad;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Refrescando vista materializada de ventas por ciudad...');
    DBMS_MVIEW.REFRESH('MV_VENTAS_POR_CIUDAD');
    DBMS_OUTPUT.PUT_LINE('Vista materializada actualizada.');
END;
/

SELECT * FROM mv_ventas_por_ciudad;

CREATE OR REPLACE PROCEDURE mostrar_top_clientes(p_limite NUMBER) AS
BEGIN
    FOR rec IN (
        SELECT c.ClienteID,
               c.Nombre,
               SUM(p.Total) AS TotalGastado,
               RANK() OVER (ORDER BY SUM(p.Total) DESC) AS Posicion
        FROM Clientes c
        JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY c.ClienteID, c.Nombre
        ORDER BY Posicion
    ) LOOP
        EXIT WHEN rec.Posicion > p_limite;
        DBMS_OUTPUT.PUT_LINE('Pos ' || rec.Posicion || ' - Cliente ' || rec.Nombre || ' | Gastado ' || rec.TotalGastado);
    END LOOP;
END mostrar_top_clientes;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA SESIÓN 17: Top clientes ===');
    mostrar_top_clientes(3);
END;
/
