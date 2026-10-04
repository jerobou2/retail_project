# retail_project
-- =====================================================
-- Descripción: Sistema de ventas retail con clientes, productos y ventas
-- =====================================================

-- Crear la base de datos
CREATE DATABASE retail_project;

-- Conectar a la base de datos (en psql: \c retail_project)

-- =====================================================
-- TABLA CLIENTES
-- =====================================================
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    edad INT CHECK (edad >= 18 AND edad <= 120)
);

-- =====================================================
-- TABLA PRODUCTOS
-- =====================================================
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
	marca VARCHAR(50),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(50)
);

-- =====================================================
-- TABLA VENTAS
-- =====================================================
CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    id_producto INT NOT NULL REFERENCES productos(id_producto) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario > 0)
);

-- =====================================================
-- CARGA DE DATOS INICIAL (TRANSACCIÓN EXPLÍCITA)
-- =====================================================

BEGIN;

-- Insertar clientes
INSERT INTO clientes (nombre, email, telefono, edad) VALUES 
('Jeronimo Bouzada', 'jero.bouzada@email.com', '1234567890', 30),
('Natalia Layus', 'nati.layus@email.com', '0987654321', 27),
('Carlos López', 'carlos.lopez@email.com', '1122334455', 42),
('Ana Martínez', 'ana.martinez@email.com', '5566778899', 29),
('Roberto Díaz', 'roberto.diaz@email.com', '9988776655', 51);

-- Insertar productos
INSERT INTO productos (nombre, marca, precio, stock, categoria) VALUES 
('Laptop Dell', 'Dell', 899.99, 15, 'Electrónica'),
('Mouse Logitech', 'Logitech', 29.99, 50, 'Accesorios'),
('Monitor Samsung', 'Samsung', 299.99, 8, 'Electrónica'),
('Teclado Mecánico', 'Corsair', 149.99, 12, 'Accesorios'),
('Webcam HD', 'Razer', 79.99, 20, 'Accesorios');

-- Insertar ventas
INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario) VALUES 
(1, 1, 1, 899.99),
(2, 2, 2, 29.99),
(3, 3, 1, 299.99),
(4, 4, 1, 149.99),
(5, 5, 3, 79.99),
(1, 2, 5, 29.99),
(2, 4, 2, 149.99);

COMMIT;

-- =====================================================
-- OPERACIÓN UPDATE - Aumentar precios de Electrónica
-- =====================================================

UPDATE productos 
SET precio = precio * 1.10 
WHERE categoria = 'Electrónica';

-- =====================================================
-- OPERACIÓN DELETE - Eliminar una venta específica
-- =====================================================

DELETE FROM ventas 
WHERE id_venta = 2 AND id_cliente = 2;

-- =====================================================
-- VERIFICACIÓN DE DATOS
-- =====================================================

SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
