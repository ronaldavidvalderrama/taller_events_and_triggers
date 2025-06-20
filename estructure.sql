-- Active: 1749956386295@@127.0.0.1@3306@pizzadb
CREATE TABLE cliente(
    id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(11) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);
CREATE TABLE combo(
    id_combo INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);
CREATE TABLE metodo_pago(
    id_metodo_de_pago INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);
CREATE TABLE tipo_producto(
    id_tipo_producto INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);
CREATE TABLE presentacion(
    id_presentacion INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);
CREATE TABLE ingrediente(
    id_ingrediente INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    stock INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);
CREATE TABLE producto(
    id_producto INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_tipo_producto INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_tipo_producto) REFERENCES tipo_producto(id_tipo_producto)
);
CREATE TABLE pedido(
    id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fecha_recogida DATETIME NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    cliente_id INT UNSIGNED NOT  NULL,
    metodo_pago_id INT UNSIGNED  NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id_cliente),
    FOREIGN KEY (metodo_pago_id) REFERENCES metodo_pago(id_metodo_de_pago)
);

CREATE TABLE detalle_pedido(
    id_detalle_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    pedido_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id_pedido)
);
CREATE TABLE factura(
    id_factura INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    fecha DATETIME NOT NULL,
    pedido_id INT UNSIGNED NOT NULL,
    cliente_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id_pedido),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id_cliente)
);


CREATE TABLE ingredientes_extra(
    id_ingrediente_extra INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    detalle_pedido_id INT UNSIGNED NOT NULL,
    ingrediente_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (detalle_pedido_id) REFERENCES detalle_pedido(id_detalle_pedido),
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id_ingrediente)
);

CREATE TABLE combo_producto(
    id_combo_extra INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    producto_id INT UNSIGNED NOT NULL,
    combo_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES producto(id_producto),
    FOREIGN KEY (combo_id) REFERENCES combo(id_combo)
);


CREATE TABLE producto_presentacion(
    id_producto_presentacion INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    producto_id INT UNSIGNED NOT NULL,
    presentacion_id INT UNSIGNED NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES producto(id_producto),
    FOREIGN KEY (presentacion_id) REFERENCES presentacion(id_presentacion)
);
CREATE TABLE detalle_pedido_producto(
    detalle_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (detalle_id) REFERENCES detalle_pedido(id_detalle_pedido),
    FOREIGN KEY (producto_id) REFERENCES producto(id_producto)
);
CREATE TABLE detalle_pedido_combo(
    detalle_id INT UNSIGNED NOT NULL,
    combo_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (detalle_id) REFERENCES detalle_pedido(id_detalle_pedido),
    FOREIGN KEY (combo_id) REFERENCES combo(id_combo)
);

DROP DATABASE pizzadb;

CREATE DATABASE pizzadb;

USE pizzadb

DROP TABLE ingrediente;



--TALLER EVENTOS

CREATE TABLE IF NOT EXISTS resumen_ventas (
fecha       DATE      PRIMARY KEY,
total_pedidos INT,
total_ingresos DECIMAL(12,2),
creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alerta_stock (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  ingrediente_id  INT UNSIGNED NOT NULL,
  stock_actual    INT NOT NULL,
  fecha_alerta    DATETIME NOT NULL,
  creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id_ingrediente)
);


--Resumen Diario Único : crear un evento que genere un resumen de ventas **una sola vez** al finalizar 
--el día de ayer y luego se elimine automáticamente llamado `ev_resumen_diario_unico`.

DELIMITER //
CREATE EVENT ev_resumen_diario_unico
ON SCHEDULE AT CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 1 SECOND
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT 
        CURDATE() - INTERVAL 1 DAY AS FECHA,
        COUNT(*) AS Total_pedidos,
        SUM(total) AS Total_ingresos
    FROM pedido
    WHERE DATE(fecha_recogida) = CURDATE() - INTERVAL 1 DAY;

END //

DELIMITER ;

DROP EVENT IF EXISTS ev_resumen_diario_unico;

-- Verificar si el evento fue creado correctamente
SHOW EVENTS LIKE 'ev_resumen_diario_unico';

-- Verificar la creación del evento
SHOW CREATE EVENT ev_resumen_diario_unico\G


--Resumen Semanal Recurrente: cada lunes a las 01:00 AM, 
--generar el total de pedidos e ingresos de la semana pasada, 
--**manteniendo** el evento para que siga ejecutándose cada semana llamado `ev_resumen_semanal`.

DELIMITER //

CREATE EVENT ev_resumen_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-06-23 01:00:00'
DO
BEGIN
    INSERT INTO resumen_ventas (fecha, total_pedidos, total_ingresos)
    SELECT
        DATE_SUB(CURRENT_DATE, INTERVAL (WEEKDAY(CURRENT_DATE) + 7) DAY) AS Fecha,
        COUNT(*) AS Total_pedidos,
        SUM(total) AS total_ingresos
    FROM pedido
    WHERE DATE(fecha_recogida) BETWEEN
        DATE_SUB(CURRENT_DATE, INTERVAL (WEEKDAY(CURRENT_DATE) + 7) DAY) AND
        DATE_SUB(CURRENT_DATE, INTERVAL (WEEKDAY(CURRENT_DATE) + 1) DAY);
END //

DELIMITER ;

DROP EVENT IF EXISTS ev_resumen_semanal;

-- Verificar si el evento fue creado correctamente
SHOW EVENTS LIKE 'ev_resumen_semanal';

-- Verificar la creación del evento
SHOW CREATE EVENT ev_resumen_semanal\G

--Alerta de Stock Bajo Única: en un futuro arranque del sistema 
--(requerimiento del sistema), generar una única pasada de alertas
-- (`alerta_stock`) de ingredientes con stock < 5, y luego autodestruir el evento.

DELIMITER //

CREATE EVENT ev_alerta_stock_bajo_unica
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO 
BEGIN
    INSERT INTO alerta_stock(ingrediente_id, stock_actual, fecha_alerta)
    SELECT 
        id_ingrediente, 
        stock, 
        NOW()
    FROM ingrediente
    WHERE stock < 5;
    
END //

DELIMITER ;

DROP EVENT IF EXISTS ev_alerta_stock_bajo_unica;

-- Verificar si el evento fue creado correctamente
SHOW EVENTS LIKE 'ev_alerta_stock_bajo_unica';

-- Verificar la creación del evento
SHOW CREATE EVENT ev_alerta_stock_bajo_unica\G

SELECT * FROM alerta_stock ORDER BY fecha_alerta DESC;


--Monitoreo Continuo de Stock: cada 30 minutos, revisar ingredientes con 
--stock < 10 e insertar alertas en `alerta_stock`, **dejando** 
--el evento activo para siempre llamado `ev_monitor_stock_bajo`.


-- CON EL ENABLE DE EVENTOS
-- Asegúrate de que el evento esté habilitado para que se ejecute automáticamente.
DELIMITER //

CREATE EVENT ENABLE ev_monitor_stock_bajo
ON SCHEDULE EVERY 30 MINUTES
DO
BEGIN
    INSERT INTO alerta_stock(ingrediente_id, stock_actual, fecha_alerta)
    SELECT 
        id_ingrediente, 
        stock, 
        NOW()
    FROM ingrediente
    WHERE stock < 10;
    
END //

DELIMITER ;

DROP EVENT IF EXISTS ev_monitor_stock_bajo;

-- Verificar si el evento fue creado correctamente
SHOW EVENTS LIKE 'ev_monitor_stock_bajo';

-- Verificar la creación del evento
SHOW CREATE EVENT ev_monitor_stock_bajo\G

-- Limpieza de Resúmenes Antiguos: una sola vez, eliminar de `resumen_ventas`
-- los registros con fecha anterior a hace 365 días y luego
-- borrar el evento llamado `ev_purgar_resumen_antiguo`.

DELIMITER //
CREATE EVENT ev_purgar_resumen_antiguo
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO 
BEGIN
    DELETE FROM resumen_ventas
    WHERE fecha < CURDATE() - INTERVAL 365 DAY;
END //

DELIMITER ;

DROP EVENT IF EXISTS ev_purgar_resumen_antiguo;

-- Verificar si el evento fue creado correctamente

SHOW EVENTS LIKE 'ev_purgar_resumen_antiguo';

-- Verificar la creación del evento
SHOW CREATE EVENT ev_purgar_resumen_antiguo\G