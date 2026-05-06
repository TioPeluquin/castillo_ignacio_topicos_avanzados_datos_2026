-- sesion1.sql: Script para la Sesión 1

-- Detener la ejecución si ocurre un error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Cambiar al PDB XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear un nuevo usuario (esquema) para el curso en el PDB
CREATE USER curso_topicos IDENTIFIED BY curso2025;

-- Otorgar privilegios necesarios al usuario
GRANT CONNECT, RESOURCE, CREATE SESSION TO curso_topicos;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO curso_topicos;
GRANT CREATE ANY TRIGGER TO curso_topicos;
GRANT UNLIMITED TABLESPACE TO curso_topicos;

-- Confirmar creación
SELECT username FROM dba_users WHERE username = 'CURSO_TOPICOS';

-- Cambiar al esquema curso_topicos
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Crear tabla Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Clientes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Clientes (
        ClienteID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Ciudad VARCHAR2(50),
        FechaNacimiento DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Clientes creada.');
END;
/

-- Crear tabla Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Pedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Pedidos (
        PedidoID NUMBER PRIMARY KEY,
        ClienteID NUMBER,
        Total NUMBER,
        FechaPedido DATE,
        CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Pedidos creada.');
END;
/

-- Crear tabla Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Productos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Productos (
        ProductoID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Precio NUMBER
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Productos creada.');
END;
/

-- Insertar datos en Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Clientes...');
    INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Clientes.');
END;
/

-- Insertar datos en Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Pedidos...');
    INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Pedidos.');
END;
/

-- Insertar datos en Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Productos...');
    INSERT INTO Productos VALUES (1, 'Laptop', 1200);
    INSERT INTO Productos VALUES (2, 'Mouse', 25);
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Productos.');
END;
/

-- Confirmar los datos insertados antes de continuar
COMMIT;

-- Confirmar creación e inserción de datos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

-- Verificar datos
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

-- Crear tabla DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos (
        DetalleID NUMBER PRIMARY KEY,
        PedidoID NUMBER,
        ProductoID NUMBER,
        Cantidad NUMBER,
        CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
        CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos creada.');
END;
/

-- Insertar datos en DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en DetallesPedidos...');
    INSERT INTO DetallesPedidos VALUES (1, 101, 1, 2); -- Pedido 101: 2 Laptops
    INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); -- Pedido 101: 5 Mouse
    DBMS_OUTPUT.PUT_LINE('Datos insertados en DetallesPedidos.');
END;
/

-- Verificar datos
SELECT * FROM DetallesPedidos;

-- ========================================
-- EJERCICIOS DE PRÁCTICA SESIÓN 2
-- ========================================

-- ========================================
-- 1. DOS SENTENCIAS SELECT SIMPLES
-- ========================================

-- SELECT simple 1: Obtener todos los nombres de clientes
SELECT Nombre FROM Clientes;

-- SELECT simple 2: Obtener todos los productos con sus precios
SELECT Nombre, Precio FROM Productos;

-- ========================================
-- 2. DOS SENTENCIAS SELECT CON FUNCIONES AGREGADAS
-- ========================================

-- Función agregada 1: Contar total de pedidos y sumar el total de dinero
SELECT COUNT(PedidoID) AS TotalPedidos, SUM(Total) AS MontroTotal FROM Pedidos;

-- Función agregada 2: Obtener el precio promedio de productos y el precio máximo
SELECT AVG(Precio) AS PrecioPromedio, MAX(Precio) AS PrecioMaximo, MIN(Precio) AS PrecioMinimo FROM Productos;

-- ========================================
-- 3. DOS SENTENCIAS SELECT CON EXPRESIONES REGULARES
-- ========================================

-- Expresión regular 1: Obtener clientes cuyo nombre comienza con 'J' o 'M'
SELECT Nombre, Ciudad FROM Clientes 
WHERE REGEXP_LIKE(Nombre, '^(J|M)');

-- Expresión regular 2: Obtener productos que contienen "a" o "o" en su nombre (case-insensitive)
SELECT Nombre, Precio FROM Productos 
WHERE REGEXP_LIKE(Nombre, 'a|o', 'i');

-- ========================================
-- 4. DOS VISTAS
-- ========================================

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


-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 3
-- ========================================

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

-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 4 (EXCEPTIONS)
-- ========================================


DECLARE
    v_producto_id NUMBER := 2;
    v_precio NUMBER;
    v_nombre_producto VARCHAR2(50);
    
    -- Declarar excepción personalizada
    precio_insuficiente EXCEPTION;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 1: Verificación de Precio ===');
    
    -- Obtener producto
    SELECT Nombre, Precio INTO v_nombre_producto, v_precio
    FROM Productos
    WHERE ProductoID = v_producto_id;
    
    -- Verificar si el precio es suficiente
    IF v_precio < 50 THEN
        RAISE precio_insuficiente;
    END IF;
    
    -- Si llegamos aquí, el precio es válido
    DBMS_OUTPUT.PUT_LINE('Producto encontrado: ' || v_nombre_producto);
    DBMS_OUTPUT.PUT_LINE('Precio: ' || v_precio);
    DBMS_OUTPUT.PUT_LINE('Estado: Precio válido ✓');
    
EXCEPTION
    WHEN precio_insuficiente THEN
        DBMS_OUTPUT.PUT_LINE('ERROR PERSONALIZADO: Precio insuficiente (' || v_precio || ')');
        DBMS_OUTPUT.PUT_LINE('Explicación: El precio debe ser >= 50 para rentabilidad.');
        
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Producto ' || v_producto_id || ' no encontrado en la base de datos.');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- ========================================
-- PRÁCTICA 2 SESIÓN 4: Inserción con ID Duplicado - Manejo de Excepción
-- ========================================


DECLARE
    v_nuevo_cliente_id NUMBER := 1; -- ID que ya existe
    v_nombre VARCHAR2(50) := 'Jorge Martínez';
    v_ciudad VARCHAR2(50) := 'Temuco';
    
    -- Excepción para violación de clave única
    dup_key_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(dup_key_exception, -1);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 2: Inserción con ID Duplicado ===');
    DBMS_OUTPUT.PUT_LINE('Intentando insertar cliente con ID: ' || v_nuevo_cliente_id);
    
    -- Intentar insertar cliente con ID duplicado
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    VALUES (v_nuevo_cliente_id, v_nombre, v_ciudad, SYSDATE);
    
    DBMS_OUTPUT.PUT_LINE('Cliente insertado exitosamente.');
    COMMIT;
    
EXCEPTION
    WHEN dup_key_exception THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Violación de clave única');
        DBMS_OUTPUT.PUT_LINE('Explicación: Ya existe un cliente con ID ' || v_nuevo_cliente_id);
        DBMS_OUTPUT.PUT_LINE('Acción: Verifique la unicidad del ID antes de insertar.');
        ROLLBACK;
        
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontraron datos en la tabla.');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Código de error: ' || SQLCODE);
        ROLLBACK;
END;
/

-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 5 (CURSORES EXPLÍCITOS)
-- ========================================

-- ========================================
-- PRÁCTICA 1: Cursor Explícito Básico - Listar Atributos Ordenados
-- ========================================

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

-- ========================================
-- PRÁCTICA 2: Cursor Explícito con Parámetro y FOR UPDATE
-- ========================================


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

-- ========================================
-- COMMIT FINAL - Guardar Todos los Cambios
-- ========================================
COMMIT;

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('SCRIPT COMPLETADO EXITOSAMENTE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Ejercicios implementados:');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 1: Tablas y datos base');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 1: Vistas y expresiones regulares');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 3: Bloque anónimo con clasificación');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 4: Manejo de excepciones personalizadas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 4: Manejo de violación de claves');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 5: Cursor explícito básico');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 5: Cursor explícito con parámetro');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Todos los cambios han sido guardados.');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
