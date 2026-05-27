-- SESION 2
-- EJERCICIOS DE PRÁCTICA SESIÓN 2

-- 1. DOS SENTENCIAS SELECT SIMPLES

-- SELECT simple 1: Obtener todos los nombres de clientes
SELECT Nombre FROM Clientes;

-- SELECT simple 2: Obtener todos los productos con sus precios
SELECT Nombre, Precio FROM Productos;

-- 2. DOS SENTENCIAS SELECT CON FUNCIONES AGREGADAS

-- Función agregada 1: Contar total de pedidos y sumar el total de dinero
SELECT COUNT(PedidoID) AS TotalPedidos, SUM(Total) AS MontroTotal FROM Pedidos;

-- Función agregada 2: Obtener el precio promedio de productos y el precio máximo
SELECT AVG(Precio) AS PrecioPromedio, MAX(Precio) AS PrecioMaximo, MIN(Precio) AS PrecioMinimo FROM Productos;

-- 3. DOS SENTENCIAS SELECT CON EXPRESIONES REGULARES

-- Expresión regular 1: Obtener clientes cuyo nombre comienza con 'J' o 'M'
SELECT Nombre, Ciudad FROM Clientes 
WHERE REGEXP_LIKE(Nombre, '^(J|M)');

-- Expresión regular 2: Obtener productos que contienen "a" o "o" en su nombre (case-insensitive)
SELECT Nombre, Precio FROM Productos 
WHERE REGEXP_LIKE(Nombre, 'a|o', 'i');

-- 4. DOS VISTAS

-- Vista 1: v_clientes_pedidos - Mostrar clientes con total de pedidos y monto total gastado
CREATE OR REPLACE VIEW v_clientes_pedidos AS
SELECT c.ClienteID, c.Nombre, c.Ciudad, 
       COUNT(p.PedidoID) AS TotalPedidos, 
       SUM(p.Total) AS MontoTotalGastado
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.ClienteID, c.Nombre, c.Ciudad;

-- Vista 2: v_detalles_productos - Mostrar detalle completo de pedidos con nombres
CREATE OR REPLACE VIEW v_detalles_productos AS
SELECT p.PedidoID, c.Nombre AS NombreCliente, 
       pr.Nombre AS NombreProducto, 
       dp.Cantidad, pr.Precio, 
       (dp.Cantidad * pr.Precio) AS SubTotal
FROM DetallesPedidos dp
JOIN Pedidos p ON dp.PedidoID = p.PedidoID
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Productos pr ON dp.ProductoID = pr.ProductoID;

-- Verificar las vistas creadas
SELECT * FROM v_clientes_pedidos;
SELECT * FROM v_detalles_productos;
