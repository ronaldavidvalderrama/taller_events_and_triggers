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