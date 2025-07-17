-- =========================================
-- USO DE BASE DE DATOS
-- =========================================
--drop DATABASE BD_AUNAMART
CREATE DATABASE BD_AUNAMART;
GO

USE BD_AUNAMART;
GO

-- =========================================
-- CREACIÓN DE DIMENSIONES
-- =========================================

IF OBJECT_ID('DimTiempo') IS NOT NULL DROP TABLE DimTiempo;
CREATE TABLE DimTiempo (
    Fecha_Id INT PRIMARY KEY,
    Fecha DATE UNIQUE,
    Anio INT,
    Mes INT,
    Nombre_Mes VARCHAR(50),
    Trimestre VARCHAR(50),
    Numero_Trimestre INT,
    Semestre INT,
    Numero_Semana INT,
    Dia_Semana VARCHAR(50),
    Numero_Dia_Semana INT,
    Dia_Del_Mes INT,
    Dia_Del_Anio INT,
    Es_Fin_De_Semana BIT,
    Es_Dia_Festivo BIT,
    Nombre_Dia_Festivo VARCHAR(255)
);
GO

--------------------------------
-- Insercion en dimension tiempo
-- truncate table DimTiempo
BEGIN TRANSACTION;
WITH Fechas AS (
-- Generar desde 2024 hasta hoy
SELECT TOP 2024
    DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2020-01-01') AS GeneratedDate

    FROM
        sys.objects AS o1
        CROSS JOIN sys.objects AS o2
)
INSERT INTO DimTiempo
(
    Fecha_Id, Fecha, Anio, Mes, Nombre_Mes, Trimestre, Numero_Trimestre,
    Semestre, Numero_Semana, Dia_Semana, Numero_Dia_Semana, Dia_Del_Mes,
    Dia_Del_Anio, Es_Fin_De_Semana, Es_Dia_Festivo, Nombre_Dia_Festivo
)
SELECT
    CAST(FORMAT(F.GeneratedDate, 'yyyyMMdd') AS INT) AS Fecha_Id,
    F.GeneratedDate AS Fecha,
    YEAR(F.GeneratedDate) AS Anio,
    MONTH(F.GeneratedDate) AS Mes,
    DATENAME(month, F.GeneratedDate) AS Nombre_Mes,
    'Q' + CAST(DATEPART(quarter, F.GeneratedDate) AS VARCHAR(1)) AS Trimestre,
    DATEPART(quarter, F.GeneratedDate) AS Numero_Trimestre,
    CASE WHEN MONTH(F.GeneratedDate) BETWEEN 1 AND 6 THEN 1 ELSE 2 END AS Semestre,
    DATEPART(wk, F.GeneratedDate) AS Numero_Semana,
    DATENAME(weekday, F.GeneratedDate) AS Dia_Semana,
    DATEPART(weekday, F.GeneratedDate) AS Numero_Dia_Semana,
    DAY(F.GeneratedDate) AS Dia_Del_Mes,
    DATEPART(dayofyear, F.GeneratedDate) AS Dia_Del_Anio,
    CASE WHEN DATENAME(weekday, F.GeneratedDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS Es_Fin_De_Semana,
    0 AS Es_Dia_Festivo, -- Por simplicidad, se asume que no son dias festivos especificos
    NULL AS Nombre_Dia_Festivo
FROM
    Fechas AS F;
COMMIT TRANSACTION;
PRINT 'Datos insertados en DimTiempo.';
GO


CREATE TABLE Dim_Plataforma (
    ID_Plataforma INT PRIMARY KEY,
    Nombre_Plataforma VARCHAR(100)
);

CREATE TABLE Dim_TipoReclamo (
    ID_TipoReclamo INT PRIMARY KEY,
    Tipo_Reclamo VARCHAR(100)
);

CREATE TABLE Dim_Categoria (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    Categoria VARCHAR(100),
    Subcategoria VARCHAR(100)
);

CREATE TABLE Dim_TipoServicio (
    TipoServicioID INT PRIMARY KEY,
    Tipo_Servicio VARCHAR(100),
    Subtipo VARCHAR(100)
);

CREATE TABLE DimRol (
    Rol_Id INT PRIMARY KEY,
    Nombre_Rol VARCHAR(100),
    Categoria_Rol VARCHAR(100),
    Nivel_Jerarquico VARCHAR(100)
);

CREATE TABLE DimMotivoSalida (
    Motivo_Salida_Id INT PRIMARY KEY,
    Motivo VARCHAR(255),
    Categoria_Motivo VARCHAR(255),
    Es_Voluntario BIT,
    Es_Evitable BIT,
    Criticidad VARCHAR(50)
);

-- =========================================
-- CREACIÓN DE HECHOS
-- =========================================

CREATE TABLE Hechos_SatisfaccionUsuario (
    ID_Paciente INT,
    Fecha_Id INT,
    ID_Plataforma INT,
    ID_TipoReclamo INT,
    Fecha_Encuesta DATETIME,
    Fecha_Calificacion DATETIME,
    Fecha_Reclamo DATETIME,
    Reclamo_Resuelto VARCHAR(10),
    Fecha_Respuesta_Reclamo DATETIME,
    Puntaje_Calidad_Atencion INT,
    Puntaje_Tiempo_Espera INT,
    Puntaje_Empleado INT,
    Puntaje_Infraestructura INT,
    Puntaje_Comunicacion INT,
    Puntaje_NPS INT,
    Puntaje_Calificacion_Online INT,
    FOREIGN KEY (Fecha_Id) REFERENCES DimTiempo(Fecha_Id),
    FOREIGN KEY (ID_Plataforma) REFERENCES Dim_Plataforma(ID_Plataforma),
    FOREIGN KEY (ID_TipoReclamo) REFERENCES Dim_TipoReclamo(ID_TipoReclamo)
);

CREATE TABLE Hechos_Rentabilidad (
    ID_Fact INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    FechaID INT,
    CategoriaID INT,
    TipoServicioID INT,
    Categoria VARCHAR(100),
    Subcategoria VARCHAR(100),
    Tipo_Registro VARCHAR(100),
    Ingresos DECIMAL(12,2),
    Costos DECIMAL(12,2),
    FOREIGN KEY (FechaID) REFERENCES DimTiempo(Fecha_Id),
    FOREIGN KEY (CategoriaID) REFERENCES Dim_Categoria(CategoriaID),
    FOREIGN KEY (TipoServicioID) REFERENCES Dim_TipoServicio(TipoServicioID)
);

CREATE TABLE Hechos_RotacionPersonal (
    ID_Empleado INT,
    FechaID INT,
    EventoSalida_Id INT,
    Fecha_Salida DATE,
    Motivo_Salida_Id INT,
    Rol_Id INT,
    Duracion_Empleo_Dias INT,
    Edad_Al_Salir INT,
    Tiempo_Puesto_Dias INT,
    Indicador_Reemplazo BIT,
    Costo_Reemplazo DECIMAL(12,2),
    FOREIGN KEY (FechaID) REFERENCES DimTiempo(Fecha_Id),
    FOREIGN KEY (Motivo_Salida_Id) REFERENCES DimMotivoSalida(Motivo_Salida_Id),
    FOREIGN KEY (Rol_Id) REFERENCES DimRol(Rol_Id)
);

-- =========================================
-- POBLADO DE DIMENSIONES
-- =========================================
-- Dim Plataforma
INSERT INTO Dim_Plataforma(ID_Plataforma, Nombre_Plataforma) VALUES
(1, 'App Móvil'),
(2, 'Sitio Web'),
(3, 'Portal Pacientes')
GO

-- DimRol
INSERT INTO DimRol (Rol_Id, Nombre_Rol)
SELECT 
    r.Rol_Id,
    r.Nombre_Rol
FROM BD_AUNA.dbo.Rol r;

-- DimMotivoSalida
INSERT INTO DimMotivoSalida (
    Motivo_Salida_Id, Motivo, Categoria_Motivo,
    Es_Voluntario, Es_Evitable
)
SELECT 
    Motivo_Salida_Id, Motivo, Categoria_Motivo,
    Es_Voluntario, Es_Evitable
FROM BD_AUNA.dbo.MotivoSalida;

-- DimCategoria
-- 1. Servicios Médicos (desde Tipo_Servicio)
INSERT INTO BD_AUNAMART.dbo.Dim_Categoria (Categoria, Subcategoria)
SELECT DISTINCT 
    'Servicios Médicos' AS Categoria,
    ts.Nombre AS Subcategoria
FROM BD_AUNA.dbo.Tipo_Servicio ts
WHERE ts.Nombre IS NOT NULL;

-- 2. Productos Farmacéuticos (desde ProductosFarmaceuticos)
INSERT INTO BD_AUNAMART.dbo.Dim_Categoria (Categoria, Subcategoria)
SELECT DISTINCT 
    'Productos Farmacéuticos' AS Categoria,
    pf.Nombre_Producto AS Subcategoria
FROM BD_AUNA.dbo.ProductosFarmaceuticos pf
WHERE pf.Nombre_Producto IS NOT NULL;

-- 3. Gastos Operativos (desde Tipo_Gasto)
INSERT INTO BD_AUNAMART.dbo.Dim_Categoria (Categoria, Subcategoria)
SELECT DISTINCT 
    'Gastos Operativos' AS Categoria,
    tg.Nombre AS Subcategoria
FROM BD_AUNA.dbo.Tipo_Gasto tg
WHERE tg.Nombre IS NOT NULL;

-- Poblarla desde Tipo_Servicio con mismo ID
INSERT INTO Dim_TipoServicio (TipoServicioID, Tipo_Servicio, Subtipo)
SELECT 
    ts.ID_Tipo_Servicio,
    CASE 
        WHEN CHARINDEX(' de ', ts.Nombre) > 0 THEN LEFT(ts.Nombre, CHARINDEX(' de ', ts.Nombre) - 1)
        ELSE LEFT(ts.Nombre, CHARINDEX(' ', ts.Nombre + ' ') - 1)
    END,
    CASE 
        WHEN CHARINDEX(' de ', ts.Nombre) > 0 THEN LTRIM(RTRIM(SUBSTRING(ts.Nombre, CHARINDEX(' de ', ts.Nombre) + 4, LEN(ts.Nombre))))
        ELSE LTRIM(RTRIM(SUBSTRING(ts.Nombre, CHARINDEX(' ', ts.Nombre + ' '), LEN(ts.Nombre))))
    END
FROM BD_AUNA.dbo.Tipo_Servicio ts;

-- =========================================
-- CARGA DE HECHOS
-- =========================================
--TRUNCATE TABLE Hechos_SatisfaccionUsuario
-- Insertar datos
INSERT INTO BD_AUNAMART.dbo.Hechos_SatisfaccionUsuario (
    ID_Paciente, 
    Fecha_Id, 
    ID_Plataforma, 
    ID_TipoReclamo,
    Fecha_Encuesta, 
    Fecha_Calificacion, 
    Fecha_Reclamo,
    Reclamo_Resuelto, 
    Fecha_Respuesta_Reclamo,
    Puntaje_Calidad_Atencion, 
    Puntaje_Tiempo_Espera, 
    Puntaje_Empleado,
    Puntaje_Infraestructura, 
    Puntaje_Comunicacion, 
    Puntaje_NPS,
    Puntaje_Calificacion_Online
)
SELECT 
    p.ID_Paciente,
    dt.Fecha_Id, 
    dp.ID_Plataforma, 
    dtr.ID_TipoReclamo,
    e.Fecha_Encuesta,
    co.Fecha_Calificacion,
    r.Fecha_Reclamo,
	r.Estado,
	r.Fecha_Respuesta,
    e.Puntaje_Calidad_Atencion,
    e.Puntaje_Tiempo_Espera,
    e.Puntaje_Empleado,
    e.Puntaje_Infraestructura,
    e.Puntaje_Comunicacion,
    e.Puntaje_NPS,
    co.Puntaje
FROM BD_AUNA.dbo.Pacientes p
LEFT JOIN BD_AUNA.dbo.Encuestas_Satisfaccion e ON p.ID_Paciente = e.ID_Paciente
LEFT JOIN BD_AUNA.dbo.Calificaciones_Online co ON p.ID_Paciente = co.ID_Paciente
LEFT JOIN BD_AUNA.dbo.Reclamos r ON p.ID_Paciente = r.ID_Paciente
LEFT JOIN BD_AUNAMART.dbo.Dim_Plataforma dp ON dp.ID_Plataforma = dp.ID_Plataforma
LEFT JOIN BD_AUNAMART.dbo.Dim_TipoReclamo dtr ON dtr.ID_TipoReclamo = dtr.ID_TipoReclamo
LEFT JOIN BD_AUNAMART.dbo.DimTiempo dt ON dt.Fecha = ISNULL(e.Fecha_Encuesta, ISNULL(co.Fecha_Calificacion, r.Fecha_Reclamo))
WHERE p.ID_Paciente IN (
    SELECT TOP 8000 ID_Paciente FROM BD_AUNA.dbo.Pacientes ORDER BY NEWID()
);

-- Hechos_RotacionPersonal
-- TRUNCATE TABLE Hechos_RotacionPersonal
INSERT INTO Hechos_RotacionPersonal (
    ID_Empleado,
	FechaID,
	EventoSalida_Id,
	Fecha_Salida,
	Motivo_Salida_Id,
    Rol_Id
)
SELECT 
    se.ID_Empleado,
    dt.Fecha_Id,
    se.ID_Salida,
    se.Fecha_Salida,
    se.ID_Motivo,
    e.Rol_Id
FROM BD_AUNA.dbo.Salidas_Empleados se
JOIN BD_AUNA.dbo.Empleado e ON se.ID_Empleado = e.ID_Empleado
JOIN BD_AUNA.dbo.Rol r ON e.Rol_Id = r.Rol_Id
JOIN BD_AUNAMART.dbo.DimTiempo dt ON dt.Fecha = se.Fecha_Salida;

-- Insertar todos los registros rentabilidad
--truncate table [dbo].[Hechos_Rentabilidad]

INSERT INTO BD_AUNAMART.dbo.Hechos_Rentabilidad (
    Fecha,
    FechaID,
    CategoriaID,
    TipoServicioID,
    Categoria,
    Subcategoria,
    Tipo_Registro,
    Ingresos,
    Costos
)
SELECT 
    CONVERT(DATE, sp.Fecha_Inicio) AS Fecha,
    dt.Fecha_Id,
    cp.ID_Categoria AS CategoriaID,
    ts.ID_Tipo_Servicio AS TipoServicioID,
    cp.Nombre AS Categoria,
    ts.Nombre AS Subcategoria,
    CASE 
        WHEN ts.Nombre LIKE '%Consulta%' OR ts.Nombre LIKE '%Cirugía%' OR ts.Nombre LIKE '%Procedimiento%' THEN 'Clínico'
        WHEN ts.Nombre LIKE '%Laboratorio%' OR ts.Nombre LIKE '%Diagnóstico%' THEN 'Diagnóstico'
        WHEN ts.Nombre LIKE '%Hospitalización%' OR ts.Nombre LIKE '%UCI%' THEN 'Hospitalario'
        ELSE 'Otros'
    END AS Tipo_Registro,
    SUM(sp.Costo_Real) AS Ingresos,
    SUM(sp.Costo_Real * 0.6) AS Costos -- Asumiendo un 60% del ingreso como costo
FROM BD_AUNA.dbo.ServiciosPrestados sp 
JOIN BD_AUNAMART.dbo.DimTiempo dt ON dt.Fecha = CONVERT(DATE, sp.Fecha_Inicio)
JOIN BD_AUNA.dbo.Tipo_Servicio ts ON sp.ID_Tipo_Servicio = ts.ID_Tipo_Servicio
LEFT JOIN BD_AUNA.dbo.Categorias_Producto cp ON 1=1 -- Asumiendo que necesitas una categoría genérica
WHERE sp.ID_ServicioPrestado IN (SELECT TOP 8000 ID_ServicioPrestado FROM BD_AUNA.dbo.ServiciosPrestados ORDER BY NEWID())
GROUP BY 
    CONVERT(DATE, sp.Fecha_Inicio),
    dt.Fecha_Id,
    cp.ID_Categoria,
    ts.ID_Tipo_Servicio,
    cp.Nombre,
    ts.Nombre,
    CASE 
        WHEN ts.Nombre LIKE '%Consulta%' OR ts.Nombre LIKE '%Cirugía%' OR ts.Nombre LIKE '%Procedimiento%' THEN 'Clínico'
        WHEN ts.Nombre LIKE '%Laboratorio%' OR ts.Nombre LIKE '%Diagnóstico%' THEN 'Diagnóstico'
        WHEN ts.Nombre LIKE '%Hospitalización%' OR ts.Nombre LIKE '%UCI%' THEN 'Hospitalario'
        ELSE 'Otros'
    END
