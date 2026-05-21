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
-- OBJETOS DE BASES DE DATOS - SESIÓN 6
-- ========================================

-- ========================================
-- Crear Tipo de Objeto: cliente_obj
-- ========================================
-- DESCRIPCIÓN:
-- Tipo de objeto que representa un cliente con atributos y métodos.
-- 
-- ATRIBUTOS:
-- - cliente_id: Identificador único del cliente
-- - nombre: Nombre completo del cliente
-- - ciudad: Ciudad donde reside el cliente
--
-- MÉTODOS:
-- - get_info(): Retorna información completa del cliente formateada
--
-- ========================================

CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || cliente_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
    END;
END;
/

-- ========================================
-- Crear Tabla Basada en Objetos
-- ========================================

CREATE TABLE clientes_obj OF cliente_obj (
    cliente_id PRIMARY KEY
);

-- Insertar datos en tabla de objetos
INSERT INTO clientes_obj VALUES (1, 'Juan Perez', 'Santiago');
INSERT INTO clientes_obj VALUES (2, 'María Gomez', 'Valparaiso');
INSERT INTO clientes_obj VALUES (3, 'Ana Lopez', 'Santiago');

COMMIT;

-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 6 (OBJETOS)
-- ========================================


DECLARE
    -- Cursor que selecciona objetos de tipo cliente_obj
    CURSOR cliente_obj_cursor IS
        SELECT VALUE(c) AS cliente
        FROM clientes_obj c
        ORDER BY c.nombre ASC;
    
    -- Variable para almacenar el objeto
    v_cliente cliente_obj;
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 1: Cursor Basado en Objeto ===');
    DBMS_OUTPUT.PUT_LINE('Listado de Clientes (Nombre - Ciudad):');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    
    -- Abrir cursor
    OPEN cliente_obj_cursor;
    
    -- Procesar filas
    LOOP
        FETCH cliente_obj_cursor INTO v_cliente;
        
        EXIT WHEN cliente_obj_cursor%NOTFOUND;
        
        v_contador := v_contador + 1;
        
        -- Acceder a atributos del objeto
        DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || v_cliente.nombre || ' - ' || v_cliente.ciudad);
        
        -- Llamar a método del objeto
        DBMS_OUTPUT.PUT_LINE('   Info Completa: ' || v_cliente.get_info());
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de clientes: ' || v_contador);
    
    -- Cerrar cursor
    CLOSE cliente_obj_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF cliente_obj_cursor%ISOPEN THEN
            CLOSE cliente_obj_cursor;
        END IF;
END;
/

-- ========================================
-- PRÁCTICA 2: Cursor Explícito con Parámetro Basado en Objeto
-- ========================================


DECLARE
    -- Cursor parametrizado basado en objeto
    CURSOR cliente_obj_param_cursor(p_ciudad VARCHAR2) IS
        SELECT VALUE(c) AS cliente
        FROM clientes_obj c
        WHERE c.ciudad = p_ciudad
        FOR UPDATE;
    
    -- Variables para almacenar datos
    v_cliente cliente_obj;
    v_ciudad_param VARCHAR2(50) := 'Santiago';
    v_contador NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRÁCTICA 2: Cursor Parametrizado de Objetos ===');
    DBMS_OUTPUT.PUT_LINE('Procesando clientes de: ' || v_ciudad_param);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    
    -- Abrir cursor con parámetro
    OPEN cliente_obj_param_cursor(v_ciudad_param);
    
    LOOP
        FETCH cliente_obj_param_cursor INTO v_cliente;
        
        EXIT WHEN cliente_obj_param_cursor%NOTFOUND;
        
        v_contador := v_contador + 1;
        
        DBMS_OUTPUT.PUT_LINE('Registro ' || v_contador || ':');
        DBMS_OUTPUT.PUT_LINE('  Información del Objeto: ' || v_cliente.get_info());
        DBMS_OUTPUT.PUT_LINE('  ID: ' || v_cliente.cliente_id);
        DBMS_OUTPUT.PUT_LINE('  Nombre: ' || v_cliente.nombre);
        DBMS_OUTPUT.PUT_LINE('  Ciudad: ' || v_cliente.ciudad);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total de clientes procesados en ' || v_ciudad_param || ': ' || v_contador);
    
    -- Cerrar cursor
    CLOSE cliente_obj_param_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        IF cliente_obj_param_cursor%ISOPEN THEN
            CLOSE cliente_obj_param_cursor;
        END IF;
END;
/
-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 7 (PROCEDIMIENTOS ALMACENADOS)
-- ========================================
CREATE OR REPLACE PROCEDURE aumentar_precio_producto (
    p_producto_id IN NUMBER, 
    p_porcentaje IN NUMBER
) AS
    v_precio_actual NUMBER;
BEGIN
    -- Intentar la actualización
    UPDATE Productos
    SET Precio = Precio + (Precio * p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    -- Si no se afectó ninguna fila, el producto no existe
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El producto con ID ' || p_producto_id || ' no existe en la base de datos.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Éxito: Precio del producto ' || p_producto_id || ' aumentado en un ' || p_porcentaje || '%.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error inesperado: ' || SQLERRM);
        ROLLBACK;
END;
/
-- PRACTICA 2 
-- Bloque de prueba para el Ejercicio 1
BEGIN
    -- Prueba con producto existente (ID 1)
    aumentar_precio_producto(1, 15); -- Aumenta 15%
    -- Prueba con producto inexistente
    aumentar_precio_producto(99, 10); 
END;
/
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente (
    p_cliente_id IN NUMBER, 
    p_cantidad OUT NUMBER
) AS
BEGIN
    -- Contar registros para el cliente dado
    SELECT COUNT(*) 
    INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;

    -- Si por alguna razón el resultado es nulo, asegurar que devuelva 0
    IF p_cantidad IS NULL THEN
        p_cantidad := 0;
    END IF;
END;
/

-- Bloque de prueba para el Ejercicio 2
DECLARE
    v_num_pedidos NUMBER;
    v_id_test NUMBER := 1;
BEGIN
    contar_pedidos_cliente(v_id_test, v_num_pedidos);
    DBMS_OUTPUT.PUT_LINE('El cliente con ID ' || v_id_test || ' tiene un total de ' || v_num_pedidos || ' pedidos.');
END;
/
-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 8
-- ========================================
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
-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 10 (PROCEDIMIENTOS ALMACENADOS AVANZADOS)
-- ========================================
CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(
    p_cliente_id IN NUMBER, 
    p_porcentaje IN NUMBER DEFAULT 10
) AS
    -- Cursor para iterar sobre los pedidos del cliente con bloqueo de filas
    CURSOR pedido_cursor IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
BEGIN
    -- Uso de bucle FOR para recorrer el cursor
    FOR pedido IN pedido_cursor LOOP
        UPDATE Pedidos
        SET Total = pedido.Total * (1 + p_porcentaje / 100)
        WHERE CURRENT OF pedido_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
    END LOOP;

    -- Verificar si se realizaron cambios[cite: 4]
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El cliente ' || p_cliente_id || ' no tiene pedidos para actualizar.');
    ELSE
        COMMIT; -- Confirmar cambios si hubo éxito[cite: 4]
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error[cite: 4]
END;
/
--EJERCICIO PRACTICO 2
CREATE OR REPLACE PROCEDURE calcular_costo_detalle(
    p_detalle_id IN NUMBER, 
    p_costo IN OUT NUMBER
) AS
    v_precio NUMBER;
    v_cantidad NUMBER;
BEGIN
    -- JOIN entre DetallesPedidos y Productos para obtener los valores[cite: 4]
    SELECT p.Precio, d.Cantidad 
    INTO v_precio, v_cantidad
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;

    p_costo := v_precio * v_cantidad;
    DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id || ': ' || p_costo);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');[cite: 4]
END;
/

-- Prueba del Ejercicio 2[cite: 4]
DECLARE
    v_costo_resultado NUMBER := 0;
BEGIN
    calcular_costo_detalle(1, v_costo_resultado);
    DBMS_OUTPUT.PUT_LINE('Valor final en variable: ' || v_costo_resultado);
END;
/
-- Prueba del Ejercicio 1[cite: 4]
EXEC actualizar_total_pedidos(1);

-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 11 (FUNCIONES ALMACENADAS)
-- ========================================
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) 
RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    -- Cálculo de años entre la fecha actual y el nacimiento
    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');[cite: 5]
END;
/

-- Prueba del Ejercicio 1
SELECT Nombre, calcular_edad_cliente(ClienteID) AS Edad FROM Clientes;
--EJERCICIO PRÁCTICO 2
CREATE OR REPLACE FUNCTION obtener_precio_promedio 
RETURN NUMBER AS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_promedio FROM Productos;
    RETURN v_promedio;
END;
/

-- Prueba del Ejercicio 2: Listar productos por encima del promedio[cite: 5]
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();
-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 12 
-- ========================================
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
-- ========================================
-- EJERCICIOS PRÁCTICOS - SESIÓN 13
-- ========================================
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
--EJERCICIO PRÁCTICO 2
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

-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 14 (HERENCIA)
-- ========================================
CREATE OR REPLACE TYPE persona_obj AS OBJECT (
    persona_id NUMBER,
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY persona_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Persona ID: ' || persona_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
    END;
END;
/

CREATE OR REPLACE TYPE cliente_persona_obj UNDER persona_obj (
    monto_total NUMBER,
    MEMBER FUNCTION get_cliente_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_persona_obj AS
    MEMBER FUNCTION get_cliente_info RETURN VARCHAR2 IS
    BEGIN
        RETURN get_info() || ', Total Gastos: ' || monto_total;
    END;
END;
/

CREATE OR REPLACE TYPE empleado_obj UNDER persona_obj (
    departamento VARCHAR2(50),
    salario NUMBER,
    MEMBER FUNCTION get_empleado_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY empleado_obj AS
    MEMBER FUNCTION get_empleado_info RETURN VARCHAR2 IS
    BEGIN
        RETURN get_info() || ', Departamento: ' || departamento || ', Salario: ' || salario;
    END;
END;
/

CREATE TABLE personas_obj OF persona_obj (
    persona_id PRIMARY KEY
);

INSERT INTO personas_obj VALUES (cliente_persona_obj(10, 'Sofía Pérez', 'Concepción', 950));
INSERT INTO personas_obj VALUES (empleado_obj(20, 'Andrés Fuentes', 'Santiago', 'Ventas', 850000));

COMMIT;

SELECT p.persona_id,
       p.nombre,
       p.ciudad,
       CASE 
           WHEN VALUE(p) IS OF (cliente_persona_obj) THEN 'Cliente'
           WHEN VALUE(p) IS OF (empleado_obj) THEN 'Empleado'
           ELSE 'Persona'
       END AS Tipo,
       TREAT(VALUE(p) AS cliente_persona_obj).monto_total AS MontoTotal,
       TREAT(VALUE(p) AS empleado_obj).departamento AS Departamento,
       TREAT(VALUE(p) AS empleado_obj).salario AS Salario
FROM personas_obj p;

SELECT VALUE(p).get_info() AS InfoBase
FROM personas_obj p;

SELECT TREAT(VALUE(p) AS cliente_persona_obj).get_cliente_info() AS InfoCliente
FROM personas_obj p
WHERE VALUE(p) IS OF (cliente_persona_obj);

SELECT TREAT(VALUE(p) AS empleado_obj).get_empleado_info() AS InfoEmpleado
FROM personas_obj p
WHERE VALUE(p) IS OF (empleado_obj);

-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 15 (PAQUETES PL/SQL)
-- ========================================
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

-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 16 (AUDITORÍA Y TRANSACCIONES)
-- ========================================
CREATE TABLE auditoria_pedidos (
    audit_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    pedido_id NUMBER,
    accion VARCHAR2(30),
    fecha TIMESTAMP,
    comentario VARCHAR2(200)
);
/

CREATE OR REPLACE TRIGGER trg_auditoria_pedidos
AFTER INSERT OR UPDATE OR DELETE ON Pedidos
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF INSERTING THEN
        INSERT INTO auditoria_pedidos(pedido_id, accion, fecha, comentario)
        VALUES(:NEW.PedidoID, 'INSERT', SYSTIMESTAMP, 'Pedido creado');
    ELSIF UPDATING THEN
        INSERT INTO auditoria_pedidos(pedido_id, accion, fecha, comentario)
        VALUES(:NEW.PedidoID, 'UPDATE', SYSTIMESTAMP, 'Pedido actualizado: total ' || :NEW.Total);
    ELSIF DELETING THEN
        INSERT INTO auditoria_pedidos(pedido_id, accion, fecha, comentario)
        VALUES(:OLD.PedidoID, 'DELETE', SYSTIMESTAMP, 'Pedido eliminado');
    END IF;
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE procesar_pedido_con_inventario(p_pedido_id IN NUMBER) AS
    CURSOR c_detalles IS
        SELECT ProductoID, Cantidad
        FROM DetallesPedidos
        WHERE PedidoID = p_pedido_id;
    v_stock NUMBER;
BEGIN
    FOR r IN c_detalles LOOP
        SELECT Cantidad INTO v_stock
        FROM Inventario
        WHERE ProductoID = r.ProductoID
        FOR UPDATE;

        IF v_stock < r.Cantidad THEN
            RAISE_APPLICATION_ERROR(-20010, 'Stock insuficiente para producto ' || r.ProductoID);
        END IF;

        UPDATE Inventario
        SET Cantidad = Cantidad - r.Cantidad
        WHERE ProductoID = r.ProductoID;
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en procesar pedido: ' || SQLERRM);
        ROLLBACK;
END procesar_pedido_con_inventario;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA SESIÓN 16: Auditoría y transacciones ===');
    procesar_pedido_con_inventario(101);
    DBMS_OUTPUT.PUT_LINE('Inventario actualizado.');
END;
/

SELECT * FROM auditoria_pedidos;

-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 17 (VISTAS MATERIALIZADAS Y FUNCIONES ANALÍTICAS)
-- ========================================
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

-- ========================================
-- EJERCICIO PRÁCTICO - SESIÓN 18 (SEGURIDAD Y ROLES)
-- ========================================
CREATE ROLE rol_analista;
/

CREATE USER analista IDENTIFIED BY analista2026;
/

GRANT CREATE SESSION TO analista;
GRANT rol_analista TO analista;
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT SELECT ON v_clientes_pedidos TO rol_analista;
GRANT SELECT ON v_detalles_productos TO rol_analista;
GRANT SELECT ON mv_ventas_por_ciudad TO rol_analista;
/

CREATE OR REPLACE PROCEDURE otorgar_permiso_analista(p_usuario VARCHAR2) AS
BEGIN
    EXECUTE IMMEDIATE 'GRANT rol_analista TO ' || p_usuario;
    DBMS_OUTPUT.PUT_LINE('Rol analista otorgado a: ' || p_usuario);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR al otorgar rol: ' || SQLERRM);
END otorgar_permiso_analista;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA SESIÓN 18: Seguridad y roles ===');
    otorgar_permiso_analista('ANALISTA');
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
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 2: Consultas y vistas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 3: Bloque anónimo con clasificación');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 4: Manejo de excepciones personalizadas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 4: Manejo de violaciones de clave');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 5: Cursor explícito básico');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 5: Cursor explícito con parámetro');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 6: Objetos y cursores de objetos');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 7: Procedimientos almacenados');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 8: Vistas y excepciones avanzadas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 10: Procedimientos almacenados avanzados');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 11: Funciones almacenadas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 12: Descuentos y triggers');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 13: Inventario y Data Warehouse');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 14: Herencia de tipos');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 15: Paquetes PL/SQL');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 16: Auditoría y transacciones');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 17: Materializadas y analíticas');
    DBMS_OUTPUT.PUT_LINE('✓ Sesión 18: Seguridad y roles');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Todos los cambios han sido guardados.');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
