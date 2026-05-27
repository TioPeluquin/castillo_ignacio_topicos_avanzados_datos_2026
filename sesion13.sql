-- SESION 13
-- EJERCICIOS PRÁCTICOS - SESIÓN 13

-- Crear tabla de apoyo
CREATE TABLE Inventario (ProductoID NUMBER PRIMARY KEY, Cantidad NUMBER);
INSERT INTO Inventario VALUES (1, 10);
INSERT INTO Inventario VALUES (2, 20);

CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
    CURSOR detalle_cursor IS SELECT ProductoID, Cantidad FROM DetallesPedidos WHERE PedidoID = p_pedido_id;
    v_stock_actual NUMBER;
BEGIN
    FOR d IN detalle_cursor LOOP
        SELECT Cantidad INTO v_stock_actual FROM Inventario WHERE ProductoID = d.ProductoID;
        
        SAVEPOINT antes_de_reducir; -- Marca punto de retorno
        
        IF v_stock_actual < d.Cantidad THEN
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente para producto ' || d.ProductoID);
        END IF;
        
        UPDATE Inventario SET Cantidad = Cantidad - d.Cantidad WHERE ProductoID = d.ProductoID;
    END LOOP;
    COMMIT; -- Confirmar si todo salió bien[cite: 7]
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error detectado: ' || SQLERRM);
        ROLLBACK TO antes_de_reducir; -- Revertir solo el último cambio fallido[cite: 7]
        COMMIT; -- Salvar lo que sí se pudo procesar
END;
/
--EJERCICIO PRACTICO 2
-- 1. Dimensión Ciudad[cite: 7]
CREATE TABLE Dim_Ciudad (CiudadID NUMBER PRIMARY KEY, Ciudad VARCHAR2(50));
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- 2. Tabla de Hechos[cite: 7]
CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER, 
    ClienteID NUMBER, 
    CiudadID NUMBER, 
    FechaID NUMBER, 
    Total NUMBER,
    CONSTRAINT fk_dw_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID)
);

-- 3. Carga ETL (Simplificada)[cite: 7]
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, 1, p.Total -- FechaID 1 como dummy
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad;

-- 4. Consulta Analítica: Ventas por Ciudad[cite: 7]
SELECT dc.Ciudad, SUM(fp.Total) AS VentasTotales
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
GROUP BY dc.Ciudad;
