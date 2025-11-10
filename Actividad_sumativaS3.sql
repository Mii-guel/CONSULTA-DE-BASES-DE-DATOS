-- CASO 1: Listado de Clientes con Rango de Renta
-- Requerimiento: Mostrar clientes con celular en un rango de renta, clasificados por tramo.
-- Variables de sustitución: &RENTA_MINIMA, &RENTA_MAXIMA
SELECT
    -- RUT Cliente con formato (99.999.999-D)
    TO_CHAR(c.numrut_cli, '99G999G999') || '-' || c.dvrut_cli AS "RUT Cliente",

    -- Nombre Completo (Nombre ApPaterno ApMaterno)
    INITCAP(c.nombre_cli) || ' ' || INITCAP(c.appaterno_cli) || ' ' || INITCAP(c.apmaterno_cli) AS "Nombre Completo Cliente",

    -- Dirección Cliente
    c.direccion_cli AS "Dirección Cliente",

    -- Renta Cliente con formato monetario
    TO_CHAR(c.renta_cli, '$999G999G999') AS "Renta Cliente",

    -- Celular Cliente con formato 00-000-0000 (ajustar formato si los datos fuente son diferentes)
    SUBSTR(TO_CHAR(c.celular_cli), 1, LENGTH(TO_CHAR(c.celular_cli)) - 8) || '-' ||
    SUBSTR(TO_CHAR(c.celular_cli), -8, 4) || '-' ||
    SUBSTR(TO_CHAR(c.celular_cli), -4, 4) AS "Celular Cliente",

    -- Tramo Renta (Clasificación Condicional CASE)
    CASE
        WHEN c.renta_cli > 500000 THEN 'TRAMO 1'
        WHEN c.renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN c.renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Tramo Renta"

FROM
    cliente c
WHERE
    -- Restricción de datos: Renta entre el rango solicitado
    c.renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
    -- Restricción de datos: Solo clientes con celular registrado
    AND c.celular_cli IS NOT NULL
ORDER BY
    "Nombre Completo Cliente" ASC;


-- -------------------------------------------------------------------------------------------------------------------------------------------------


-- CASO 2: Sueldo Promedio por Categoría de Empleado
-- Requerimiento: Contar empleados y calcular sueldo promedio por categoría y sucursal, filtrando grupos por promedio mínimo.
-- Variable de sustitución: &SUELDO_PROMEDIO_MINIMO
SELECT
    -- Código de Categoría
    ce.id_categoria_emp AS CODIGO_CATEGORIA,

    -- Descripción de Categoría
    ce.desc_categoria_emp AS DESCRIPCION_CATEGORIA,

    -- Cantidad de Empleados (Función de Grupo COUNT)
    COUNT(e.numrut_emp) AS CANTIDAD_EMPLOYEES,

    -- Nombre de la Sucursal
    s.desc_sucursal AS SUCURSAL,

    -- Sueldo Promedio, redondeado a entero y con formato monetario (Función de Grupo AVG)
    TO_CHAR(ROUND(AVG(e.sueldo_emp)), '$99G999G999') AS SUELDO_PROMEDIO

FROM
    empleado e
JOIN
    categoria_empleado ce ON e.id_categoria_emp = ce.id_categoria_emp
JOIN
    sucursal s ON e.id_sucursal = s.id_sucursal
GROUP BY
    -- Agrupación por Categoría y Sucursal
    ce.id_categoria_emp, ce.desc_categoria_emp, s.desc_sucursal
HAVING
    -- Restricción de grupo: Sueldo promedio superior al valor ingresado por el usuario
    AVG(e.sueldo_emp) > &SUELDO_PROMEDIO_MINIMO
ORDER BY
    -- Ordenamiento: Sueldo promedio descendente
    AVG(e.sueldo_emp) DESC;


-- -------------------------------------------------------------------------------------------------------------------------------------------------


-- CASO 3: Arriendo Promedio por Tipo de Propiedad
-- Requerimiento: Total de propiedades, promedios de arriendo y superficie, razón de arriendo/m2 y clasificación.
SELECT
    -- Código de Tipo de Propiedad
    tp.id_tipo_propiedad AS CODIGO_TIPO,

    -- Descripción de Tipo de Propiedad
    tp.desc_tipo_propiedad AS DESCRIPCION_TIPO,

    -- Total de Propiedades por grupo (Función de Grupo COUNT)
    COUNT(p.nro_propiedad) AS TOTAL_PROPIEDADES,

    -- Promedio de Valor de Arriendo, redondeado a entero y con formato monetario (Función de Grupo AVG)
    TO_CHAR(ROUND(AVG(p.valor_arriendo)), '$999G999G999') AS PROMEDIO_ARRIENDO,

    -- Promedio de Superficie, redondeado a dos decimales (Función de Grupo AVG)
    ROUND(AVG(p.superficie), 2) AS PROMEDIO_SUPERFICIE,

    -- Valor Arriendo por M2 (promedio), redondeado a entero y con formato monetario (Función de Grupo AVG)
    TO_CHAR(ROUND(AVG(p.valor_arriendo / p.superficie)), '$99G999G999') AS VALOR_ARRIENDO_M2,

    -- Clasificación basada en el promedio de arriendo por m2 (Condicional CASE)
    CASE
        WHEN AVG(p.valor_arriendo / p.superficie) > 10000 THEN 'Alto'
        WHEN AVG(p.valor_arriendo / p.superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Económico'
    END AS CLASIFICACION

FROM
    propiedad p
JOIN
    tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
GROUP BY
    -- Agrupación por Tipo de Propiedad
    tp.id_tipo_propiedad, tp.desc_tipo_propiedad
HAVING
    -- Restricción de grupo: Promedio de arriendo por m2 mayor a 1.000
    AVG(p.valor_arriendo / p.superficie) > 1000
ORDER BY
    -- Ordenamiento: Valor de Arriendo por M2 (promedio) descendente
    AVG(p.valor_arriendo / p.superficie) DESC;