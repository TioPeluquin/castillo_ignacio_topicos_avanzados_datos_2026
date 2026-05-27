-- SESION 4
-- EJERCICIOS PRÁCTICOS - SESIÓN 4 (EXCEPTIONS)

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

-- PRÁCTICA 2 SESIÓN 4: Inserción con ID Duplicado - Manejo de Excepción


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
