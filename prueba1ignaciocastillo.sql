--1 relación muchos a muchos es cuando 2 tablas pueden conectar con 1 o múltiples variables de cada tabla, esto en sql no esta permitido debido a la regla de atomicidad, para ello se crean tablas intermediarias para el guardado de esos elementos en sql, en la tabla Agentes y la tabla Incidentes esta la relación de muchos a muchos ya que a un incidente se le puede asignar a muchos agentes, y un agente puede tener muchos incidentes, para eso se crea la tabla asignación en donde se guardan la combinación de datos entre las 2 tablas con una referencia de las 2 tablas  --


--2 Las vistas son consultas creadas previamente para simplemente invocar una vista en la base de datos
CREATE OR REPLACE VIEW v_horas as
select a.Horas, i.Descripcion, i.Severidad from Incidentes i
join Asingaciones a ON a.IncidenteID = i.IncidenteID;--


--3 Las excepciones predifinidas son excepciones definidas directamente en sql, se usan para proteger por así decirlo el código sql, se maneja con bloques anónimos y se puede utilizar cualquiera para que cuando se encuentre un error de syntaxis muestre un mensaje en pantalla que no es encontró un elemento, se divide por 0, etc
NO_DATA_FOUND se utiliza para cuando no encuentre una variable o dato a buscar, podamos sustituir el error con un mensaje para el usuario como "No se encontró el elemento buscado"--


--4 Los cursores explicitos son bloques de códigos que se utilizan para realizar operaciones, usa funciones como cursor, open, con eso le damos datos a nuestras tablas para iterar con cursores--


--5 SET SERVEROUTPUT ON--