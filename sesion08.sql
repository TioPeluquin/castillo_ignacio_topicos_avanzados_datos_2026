-- SESION 8
-- EJERCICIOS PRÁCTICOS - SESIÓN 8

SELECT Nombre FROM Clientes
WHERE ClienteID IN (
    SELECT ClienteID FROM Pedidos
    WHERE Total > (SELECT AVG(Total) FROM Pedidos)
);
CREATE OR REPLACE VIEW PedidosPorCiudad AS
SELECT c.Ciudad, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Ciudad;

DECLARE
    v_total NUMBER := 600;
    v_clasificacion VARCHAR2(20);
BEGIN
    v_clasificacion := CASE 
        WHEN v_total > 1000 THEN 'Alto'
        WHEN v_total > 500 THEN 'Medio'
        ELSE 'Bajo'
    END;
    DBMS_OUTPUT.PUT_LINE('Clasificación: ' || v_clasificacion);
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Problema con los datos.');
END;
/
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -8001);
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad)
    VALUES (1, 'Carlos Ruiz', 'Concepción'); -- ID 1 ya existe
EXCEPTION
    WHEN unique_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violación de clave única (TT8001).');
END;
/
DECLARE
    CURSOR pedido_cursor IS
        SELECT p.PedidoID, p.Total, c.Nombre
        FROM Pedidos p
        JOIN Clientes c ON p.ClienteID = c.ClienteID
        WHERE p.Total > 500;
    v_pedido_id NUMBER; v_total NUMBER; v_nombre VARCHAR2(50);
BEGIN
    OPEN pedido_cursor;
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total, v_nombre;
        EXIT WHEN pedido_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ': Total ' || v_total || ', Cliente: ' || v_nombre);
    END LOOP;
    CLOSE pedido_cursor;
END;
/
DECLARE
    CURSOR producto_cursor IS
        SELECT ProductoID, Precio FROM Productos
        WHERE Precio < 1000 FOR UPDATE;
    v_id NUMBER; v_precio NUMBER;
BEGIN
    OPEN producto_cursor;
    LOOP
        FETCH producto_cursor INTO v_id, v_precio;
        EXIT WHEN producto_cursor%NOTFOUND;
        UPDATE Productos SET Precio = v_precio * 1.15
        WHERE CURRENT OF producto_cursor;
    END LOOP;
    CLOSE producto_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF producto_cursor%ISOPEN THEN CLOSE producto_cursor; END IF;
END;
/
DECLARE
    CURSOR cliente_cursor IS
        SELECT c.Nombre, SUM(p.Total) AS Acumulado
        FROM Clientes c
        JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY c.Nombre
        HAVING SUM(p.Total) > 1000;
    v_nom VARCHAR2(50); v_total NUMBER;
BEGIN
    FOR r IN cliente_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || r.Nombre || ' | Total: ' || r.Acumulado);
    END LOOP;
END;
/
DECLARE
    CURSOR detalle_cursor IS
        SELECT dp.DetalleID, dp.Cantidad
        FROM DetallesPedidos dp
        JOIN Pedidos p ON dp.PedidoID = p.PedidoID
        WHERE p.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
        FOR UPDATE OF dp.Cantidad;
BEGIN
    FOR r IN detalle_cursor LOOP
        UPDATE DetallesPedidos SET Cantidad = Cantidad + 1
        WHERE CURRENT OF detalle_cursor;
    END LOOP;
    COMMIT;
END;
/
-- 1. Crear Tipo y Cuerpo
CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || cliente_id || ', Nombre: ' || nombre;
    END;
END;
/
-- 2. Tabla de Objetos y transferencia
CREATE TABLE Clientes_Obj OF cliente_obj (cliente_id PRIMARY KEY);
INSERT INTO Clientes_Obj (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;

-- 3. Cursor para listar usando el método del objeto
DECLARE
    CURSOR c_obj IS SELECT VALUE(c) AS cli FROM Clientes_Obj c;
    v_obj cliente_obj;
BEGIN
    OPEN c_obj;
    LOOP
        FETCH c_obj INTO v_obj;
        EXIT WHEN c_obj%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_obj.get_info());
    END LOOP;
    CLOSE c_obj;
END;
/
