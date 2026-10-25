-- ============================================================
-- Pre-entrega Modulo 4: Consultas multicapa para analisis de negocio
-- Alumno: Jeronimo Bouzada | Comision 93635
-- Ejecutar conectado a la base retail_project (pgAdmin 4 o psql)
-- ============================================================


-- ============================================================
-- PREPARACION: tabla categorias y relacion con productos
-- (la consigna pide unir ventas, productos y categorias)
-- ============================================================

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO categorias (nombre) VALUES
('Electronica'),
('Indumentaria'),
('Calzado'),
('Hogar')
ON CONFLICT (nombre) DO NOTHING;

-- Se agrega la clave foranea a productos y se completa desde la columna de texto "categoria"
ALTER TABLE productos ADD COLUMN IF NOT EXISTS id_categoria INT REFERENCES categorias(id_categoria);

UPDATE productos p
SET id_categoria = c.id_categoria
FROM categorias c
WHERE c.nombre = p.categoria
  AND p.id_categoria IS NULL;

-- Cliente registrado sin compras (dato de prueba para la consulta 2)
INSERT INTO clientes (id_cliente, nombre, email, telefono, edad) VALUES
(6, 'Federico Lopez', 'federico.lopez@mail.com', NULL, 40)
ON CONFLICT DO NOTHING;


-- ============================================================
-- CONSULTA 1: Rentabilidad por categoria
-- Problema de negocio: saber que categorias generan mas unidades e ingresos
-- para decidir donde concentrar compras, stock y promociones.
-- Umbral definido en 2 unidades vendidas porque una sola venta aislada
-- no indica rotacion real de la categoria.
-- ============================================================

SELECT
    cat.nombre AS categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * v.precio_unitario) AS ingreso_total
FROM ventas v
JOIN productos p ON p.id_producto = v.id_producto
JOIN categorias cat ON cat.id_categoria = p.id_categoria
GROUP BY cat.nombre
HAVING SUM(v.cantidad) >= 2
ORDER BY ingreso_total DESC;


-- ============================================================
-- CONSULTA 2: Clientes sin compras
-- Problema de negocio: clientes registrados que nunca compraron.
-- Son candidatos a campanas de primera compra, y para contactarlos
-- conviene tener su telefono.
-- LEFT JOIN conserva a todos los clientes; el HAVING filtra los que
-- no tienen ninguna venta. COALESCE muestra 'Sin telefono' en lugar de NULL
-- cuando el cliente no cargo su numero.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre AS cliente,
    COALESCE(c.telefono, 'Sin telefono') AS telefono,
    COUNT(v.id_venta) AS total_compras
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.telefono
HAVING COUNT(v.id_venta) = 0;


-- ============================================================
-- CONSULTA 3: Compras por cliente y producto
-- Problema de negocio: saber que producto compra cada cliente con mas frecuencia
-- para ofrecerle recomendaciones personalizadas.
-- Se ordena por cliente y por veces comprado de mayor a menor:
-- la primera fila de cada cliente es su producto favorito.
-- ============================================================

SELECT
    c.nombre AS cliente,
    p.nombre AS producto,
    COUNT(v.id_venta) AS veces_comprado
FROM clientes c
JOIN ventas v ON v.id_cliente = c.id_cliente
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY c.nombre, p.nombre
ORDER BY c.nombre, veces_comprado DESC;
