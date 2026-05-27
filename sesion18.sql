-- SESION 18
-- EJERCICIO PRÁCTICO - SESIÓN 18 (SEGURIDAD Y ROLES)

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

-- COMMIT FINAL - Guardar Todos los Cambios
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
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Todos los cambios han sido guardados.');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
