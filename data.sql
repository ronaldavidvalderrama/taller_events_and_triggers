-- Active: 1749956386295@@127.0.0.1@3306@pizzadb
INSERT INTO cliente (nombre, telefono, direccion) VALUES
('Juan Perez', '987654321', 'Av. Siempre Viva 123'),
('Maria Lopez', '912345678', 'Calle Falsa 456'),
('Carlos Gomez', '998877665', 'Plaza Mayor 789');

-- Metodo de pago
INSERT INTO metodo_pago (nombre) VALUES
('Efectivo'),
('Tarjeta de Crédito'),
('nequi'),
('bancolombia');

-- Tipo de producto
INSERT INTO tipo_producto (nombre) VALUES
('Pizzas'),
('Bebidas');



DELETE FROM pedido;
ALTER TABLE pedido AUTO_INCREMENT = 1;


--TABLA PEDIDO
INSERT INTO pedido (fecha_recogida, total, cliente_id, metodo_pago_id) VALUES
('2023-06-01 12:00:00', 50000, 1, 1),
('2023-06-02 13:30:00', 12000, 2, 2),
('2023-06-03 14:45:00', 30000, 3, 3);


-- TABLA COMBO 
INSERT INTO combo (nombre, precio) VALUES
('Combo Familiar', 45000),
('Combo Pareja', 30000),
('Combo Individual', 20000);


--TABLA PRESENTACION
INSERT INTO presentacion (nombre) VALUES
('Pequeña'),
('Mediana'),
('Grande');


-- TABLA INGREDIENTE
INSERT INTO ingrediente (nombre, stock, precio) VALUES
('Queso', 100, 1000),
('Jamón', 50, 1500),
('Champiñones', 70, 1200);


-- TABLA PRODUCTO
INSERT INTO producto (nombre, id_tipo_producto) VALUES
('Pizza Hawaiana', 1),
('Pizza Pepperoni', 1),
('Gaseosa 500ml', 2),
('Agua Mineral', 2);

-- DETALLE PEDIDO
INSERT INTO detalle_pedido (cantidad, pedido_id) VALUES
(2, 1),
(1, 2),
(3, 3);

-- TABLA FACTURA
INSERT INTO factura (cliente, total, fecha, pedido_id, cliente_id) VALUES
('Juan Perez', 50000, '2023-06-01 12:00:00', 1, 1),
('Maria Lopez', 12000, '2023-06-02 13:30:00', 2, 2),
('Carlos Gomez', 30000, '2023-06-03 14:45:00', 3, 3);

-- INFREDIENTE EXTRA
INSERT INTO ingredientes_extra (cantidad, detalle_pedido_id, ingrediente_id) VALUES
(1, 1, 1),
(2, 1, 2),
(1, 2, 3);

-- COMBO PRODUCTO
INSERT INTO combo_producto (producto_id, combo_id) VALUES
(1, 1),
(3, 1),
(2, 2),
(4, 2);

--producto_presentacion
INSERT INTO producto_presentacion (producto_id, presentacion_id, precio) VALUES
(1, 1, 18000),
(1, 2, 25000),
(2, 2, 24000),
(3, 1, 3000),
(4, 1, 2000);

--detalle_pedido_producto
INSERT INTO detalle_pedido_producto (detalle_id, producto_id) VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 4);

--detalle_pedido_combo
INSERT INTO detalle_pedido_combo (detalle_id, combo_id) VALUES
(2, 2),
(3, 1);
