-- ============================================================
-- Retail Project - Pre-entrega: tablas principales con restricciones y datos iniciales
-- Alumno: Jeronimo Bouzada | Comision 93635
-- Ejecutar con: psql -U usuario -f retail_project.sql
-- ============================================================

-- 1. Crear la base de datos (debe ir fuera de una transaccion)
CREATE DATABASE retail_project;

-- Conectarse a la base recien creada
\c retail_project

-- ============================================================
-- DDL: estructura de tablas
-- ============================================================

-- Tabla de clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    edad INT CHECK (edad >= 18 AND edad <= 120),
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Tabla de productos
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    marca VARCHAR(50),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(50),
    fecha_creacion DATE DEFAULT CURRENT_DATE
);

-- Tabla de ventas (se crea al final, porque depende de clientes y productos)
CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    id_producto INT NOT NULL REFERENCES productos(id_producto) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario > 0),
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- DML: carga inicial de datos (una sola transaccion)
-- ============================================================

BEGIN;

INSERT INTO clientes (id_cliente, nombre, email, telefono, edad) VALUES
(1, 'Ana Perez', 'ana.perez@mail.com', '1122334455', 34),
(2, 'Bruno Gomez', 'bruno.gomez@mail.com', '1133445566', 28),
(3, 'Carla Ruiz', 'carla.ruiz@mail.com', NULL, 45),
(4, 'Diego Soto', 'diego.soto@mail.com', '1155667788', 52),
(5, 'Eva Martinez', 'eva.martinez@mail.com', '1166778899', 23);

INSERT INTO productos (id_producto, nombre, marca, precio, stock, categoria) VALUES
(1, 'Notebook 14"', 'Lenovo', 850000.00, 10, 'Electronica'),
(2, 'Auriculares Bluetooth', 'Sony', 120000.00, 25, 'Electronica'),
(3, 'Remera basica', 'Basic', 15000.00, 80, 'Indumentaria'),
(4, 'Zapatillas running', 'Nike', 180000.00, 15, 'Calzado'),
(5, 'Cafetera express', 'Oster', 95000.00, 0, 'Hogar');

INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 850000.00),
(2, 2, 2, 120000.00),
(3, 3, 3, 15000.00),
(4, 4, 1, 180000.00),
(5, 5, 1, 95000.00),
(1, 2, 1, 120000.00),
(2, 3, 2, 15000.00);

COMMIT;

-- ============================================================
-- Mantenimiento: UPDATE y DELETE con WHERE
-- ============================================================

-- Aumentar 10% el precio de todos los productos de la categoria Electronica
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Electronica';

-- Eliminar una venta de prueba (doble condicion para mayor seguridad)
DELETE FROM ventas
WHERE id_venta = 2 AND id_cliente = 2;

-- ============================================================
-- Verificacion de la carga
-- ============================================================

SELECT COUNT(*) AS total_clientes FROM clientes;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT COUNT(*) AS total_ventas FROM ventas;

-- ============================================================
-- Prueba de restricciones (opcional): descomentar para verificar que se rechazan
-- ============================================================

-- INSERT INTO clientes (nombre, email, edad) VALUES ('Prueba', 'prueba@mail.com', 15);  -- falla: edad < 18
-- INSERT INTO productos (nombre, precio, stock) VALUES ('Error', -100.00, 5);            -- falla: precio <= 0
