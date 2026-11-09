-- ============================================================
-- Pre-entrega: Script de analisis avanzado con Window Functions
-- Alumno: Jeronimo Bouzada | Comision 93635
-- Requisito: haber ejecutado retail_project.sql y pre-entrega-modulo4.sql
--            (la tabla categorias y productos.id_categoria deben existir).
-- Ejecutar conectado a la base retail_project (pgAdmin 4 o psql).
-- ============================================================


-- ============================================================
-- CTE 1: ventas_mensuales
-- Agrupa las ventas por mes y categoria y suma el monto total.
-- DATE_TRUNC('month', ...) normaliza todas las fechas al primer dia del mes,
-- para que todas las ventas de un mismo mes caigan en la misma fila.
-- ============================================================

WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', v.fecha_venta)::DATE AS mes,
        cat.nombre AS categoria,
        SUM(v.cantidad * v.precio_unitario) AS venta_total
    FROM ventas v
    JOIN productos p ON p.id_producto = v.id_producto
    JOIN categorias cat ON cat.id_categoria = p.id_categoria
    GROUP BY DATE_TRUNC('month', v.fecha_venta)::DATE, cat.nombre
),


-- ============================================================
-- CTE 2: metricas_ventana
-- Sobre ventas_mensuales calcula:
--   - ranking_mes: posicion de la categoria dentro de cada mes segun ventas
--     (RANK con PARTITION BY mes).
--   - venta_acumulada: total acumulado de la categoria mes a mes
--     (SUM con ORDER BY mes; sin ORDER BY daria el total general en cada fila).
--   - promedio_categoria: promedio historico mensual de la categoria,
--     usado como referencia para la comparativa.
-- ============================================================

metricas_ventana AS (
    SELECT
        vm.mes,
        vm.categoria,
        vm.venta_total,
        RANK() OVER (
            PARTITION BY vm.mes
            ORDER BY vm.venta_total DESC
        ) AS ranking_mes,
        SUM(vm.venta_total) OVER (
            PARTITION BY vm.categoria
            ORDER BY vm.mes
        ) AS venta_acumulada,
        AVG(vm.venta_total) OVER (
            PARTITION BY vm.categoria
        ) AS promedio_categoria
    FROM ventas_mensuales vm
)


-- ============================================================
-- SELECT FINAL: reporte
-- Compara la venta del mes contra el promedio historico de la categoria.
-- "Exitoso" si la venta del mes iguala o supera el promedio;
-- "Bajo el promedio" en caso contrario.
-- ============================================================

SELECT
    mv.mes,
    mv.categoria,
    mv.venta_total,
    mv.ranking_mes,
    mv.venta_acumulada,
    CASE
        WHEN mv.venta_total >= mv.promedio_categoria THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS comparativa
FROM metricas_ventana mv
ORDER BY mv.mes, mv.ranking_mes;
