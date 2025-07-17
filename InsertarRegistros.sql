--Insertar BD_AUNA
USE BD_AUNA;
GO

------------------------------------------------------------------
-- Tabla Pacientes (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Pacientes (
    ID_Paciente, Nombre, Apellido, 
    DNI, Fecha_Nacimiento, Sexo, 
    Telefono, Correo, Direccion, 
    Fecha_Registro, Activo
)
SELECT 
    ID,
    -- Nombres aleatorios
    CASE 
        WHEN ID % 20 = 0 THEN 'Juan'
        WHEN ID % 20 = 1 THEN 'María'
        WHEN ID % 20 = 2 THEN 'Carlos'
        WHEN ID % 20 = 3 THEN 'Ana'
        WHEN ID % 20 = 4 THEN 'Luis'
        WHEN ID % 20 = 5 THEN 'Laura'
        WHEN ID % 20 = 6 THEN 'Pedro'
        WHEN ID % 20 = 7 THEN 'Sofía'
        WHEN ID % 20 = 8 THEN 'Jorge'
        WHEN ID % 20 = 9 THEN 'Lucía'
        WHEN ID % 20 = 10 THEN 'Miguel'
        WHEN ID % 20 = 11 THEN 'Elena'
        WHEN ID % 20 = 12 THEN 'Pablo'
        WHEN ID % 20 = 13 THEN 'Carmen'
        WHEN ID % 20 = 14 THEN 'David'
        WHEN ID % 20 = 15 THEN 'Isabel'
        WHEN ID % 20 = 16 THEN 'Fernando'
        WHEN ID % 20 = 17 THEN 'Paula'
        WHEN ID % 20 = 18 THEN 'Javier'
        ELSE 'Teresa'
    END,
    -- Apellidos aleatorios
    CASE 
        WHEN ID % 15 = 0 THEN 'García'
        WHEN ID % 15 = 1 THEN 'Rodríguez'
        WHEN ID % 15 = 2 THEN 'González'
        WHEN ID % 15 = 3 THEN 'Fernández'
        WHEN ID % 15 = 4 THEN 'López'
        WHEN ID % 15 = 5 THEN 'Martínez'
        WHEN ID % 15 = 6 THEN 'Sánchez'
        WHEN ID % 15 = 7 THEN 'Pérez'
        WHEN ID % 15 = 8 THEN 'Gómez'
        WHEN ID % 15 = 9 THEN 'Martín'
        WHEN ID % 15 = 10 THEN 'Jiménez'
        WHEN ID % 15 = 11 THEN 'Ruiz'
        WHEN ID % 15 = 12 THEN 'Hernández'
        WHEN ID % 15 = 13 THEN 'Díaz'
        ELSE 'Moreno'
    END,
    -- DNI único (8 dígitos)
    RIGHT('00000000' + CAST(10000000 + ID AS VARCHAR), 8),
    -- Fecha de nacimiento (entre 18 y 90 años atrás)
    DATEADD(YEAR, -18 - (ID % 72), DATEADD(DAY, ID % 365, DATEADD(MONTH, ID % 12, '2000-01-01'))),
    -- Sexo
    CASE WHEN ID % 2 = 0 THEN 'M' ELSE 'F' END,
    -- Teléfono (9 dígitos)
    CASE WHEN ID = 0 THEN NULL ELSE '9' + RIGHT('00000000' + CAST(10000000 + (ID * 7) % 90000000 AS VARCHAR), 8) END,
    -- Correo electrónico
    CASE 
        WHEN ID < 0 THEN NULL 
        ELSE 
            LOWER(
                CASE 
                    WHEN ID % 20 = 0 THEN 'juan'
                    WHEN ID % 20 = 1 THEN 'maria'
                    WHEN ID % 20 = 2 THEN 'carlos'
                    WHEN ID % 20 = 3 THEN 'ana'
                    WHEN ID % 20 = 4 THEN 'luis'
                    WHEN ID % 20 = 5 THEN 'laura'
                    WHEN ID % 20 = 6 THEN 'pedro'
                    WHEN ID % 20 = 7 THEN 'sofia'
                    WHEN ID % 20 = 8 THEN 'jorge'
                    WHEN ID % 20 = 9 THEN 'lucia'
                    WHEN ID % 20 = 10 THEN 'miguel'
                    WHEN ID % 20 = 11 THEN 'elena'
                    WHEN ID % 20 = 12 THEN 'pablo'
                    WHEN ID % 20 = 13 THEN 'carmen'
                    WHEN ID % 20 = 14 THEN 'david'
                    WHEN ID % 20 = 15 THEN 'isabel'
                    WHEN ID % 20 = 16 THEN 'fernando'
                    WHEN ID % 20 = 17 THEN 'paula'
                    WHEN ID % 20 = 18 THEN 'javier'
                    ELSE 'teresa'
                END
            ) + '.' +
            LOWER(
                CASE 
                    WHEN ID % 15 = 0 THEN 'garcia'
                    WHEN ID % 15 = 1 THEN 'rodriguez'
                    WHEN ID % 15 = 2 THEN 'gonzalez'
                    WHEN ID % 15 = 3 THEN 'fernandez'
                    WHEN ID % 15 = 4 THEN 'lopez'
                    WHEN ID % 15 = 5 THEN 'martinez'
                    WHEN ID % 15 = 6 THEN 'sanchez'
                    WHEN ID % 15 = 7 THEN 'perez'
                    WHEN ID % 15 = 8 THEN 'gomez'
                    WHEN ID % 15 = 9 THEN 'martin'
                    WHEN ID % 15 = 10 THEN 'jimenez'
                    WHEN ID % 15 = 11 THEN 'ruiz'
                    WHEN ID % 15 = 12 THEN 'hernandez'
                    WHEN ID % 15 = 13 THEN 'diaz'
                    ELSE 'moreno'
                END
            ) + CAST(ID % 100 AS VARCHAR) +
            CASE WHEN ID % 3 = 0 THEN '@gmail.com' WHEN ID % 3 = 1 THEN '@hotmail.com' ELSE '@yahoo.com' END
    END,
    -- Dirección
    CASE 
        WHEN ID % 10 = 0 THEN 'Av. Lima ' + CAST(100 + ID % 900 AS VARCHAR) + ', Lima'
        WHEN ID % 10 = 1 THEN 'Av. Arequipa ' + CAST(100 + ID % 900 AS VARCHAR) + ', Arequipa'
        WHEN ID % 10 = 2 THEN 'Jr. Cusco ' + CAST(100 + ID % 900 AS VARCHAR) + ', Cusco'
        WHEN ID % 10 = 3 THEN 'Calle Tacna ' + CAST(100 + ID % 900 AS VARCHAR) + ', Tacna'
        WHEN ID % 10 = 4 THEN 'Av. Puno ' + CAST(100 + ID % 900 AS VARCHAR) + ', Puno'
        WHEN ID % 10 = 5 THEN 'Jr. Ayacucho ' + CAST(100 + ID % 900 AS VARCHAR) + ', Ayacucho'
        WHEN ID % 10 = 6 THEN 'Av. Ica ' + CAST(100 + ID % 900 AS VARCHAR) + ', Ica'
        WHEN ID % 10 = 7 THEN 'Calle Huancayo ' + CAST(100 + ID % 900 AS VARCHAR) + ', Huancayo'
        WHEN ID % 10 = 8 THEN 'Av. Trujillo ' + CAST(100 + ID % 900 AS VARCHAR) + ', Trujillo'
        ELSE 'Jr. Chiclayo ' + CAST(100 + ID % 900 AS VARCHAR) + ', Chiclayo'
    END,
    -- Fecha de registro (últimos 5 años)
    DATEADD(DAY, - (ID % 1825), GETDATE()),
    -- Activo (80% activos, 20% inactivos)
    CASE WHEN ID % 5 = 0 THEN 0 ELSE 1 END
FROM Numbers;

------------------------------------------------------------------
--					   Indicador Rotacion_Personal   				--
------------------------------------------------------------------

------------------------------------------------------------------
--			   Insertar registros Tabla EstadoCivil				--
------------------------------------------------------------------

BEGIN TRANSACTION;
INSERT INTO EstadoCivil (Estado_Civil_Id, Nombre_EstadoCivil) VALUES
(1, 'Soltero'),
(2, 'Casado'),
(3, 'Divorciado'),
(4, 'Viudo'),
(5, 'Unión Libre'),
(6, 'Separado');
COMMIT TRANSACTION;
GO

------------------------------------------------------------------
--			   Insertar registros Tabla Rol   					--
------------------------------------------------------------------
BEGIN TRANSACTION;
INSERT INTO Rol (Rol_Id, Nombre_Rol) VALUES
(1, 'Médico General'),
(2, 'Enfermero/a'),
(3, 'Recepcionista'),
(4, 'Administrador/a Clínico'),
(5, 'Técnico de Laboratorio'),
(6, 'Cirujano/a'),
(7, 'Pediatra'),
(8, 'Radiólogo/a'),
(9, 'Nutricionista'),
(10, 'Fisioterapeuta'),
(11, 'Personal de Limpieza'),
(12, 'Seguridad');
COMMIT TRANSACTION;
GO

------------------------------------------------------------------
-- Tabla Empleado (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Empleado (
    ID_Empleado, Nombre, Apellido_Paterno, Apellido_Materno, 
    Fecha_Nacimiento, Genero, Estado_Civil_Id, Rol_Id, 
    Departamento, Fecha_Contratacion, Fecha_Salida,
    Nivel_Educacion, Anios_Experiencia, Salario, Activo
)
SELECT 
    ID,
    -- Nombres aleatorios
    CASE 
        WHEN ID % 20 = 0 THEN 'Juan'
        WHEN ID % 20 = 1 THEN 'María'
        WHEN ID % 20 = 2 THEN 'Carlos'
        WHEN ID % 20 = 3 THEN 'Ana'
        WHEN ID % 20 = 4 THEN 'Luis'
        WHEN ID % 20 = 5 THEN 'Laura'
        WHEN ID % 20 = 6 THEN 'Pedro'
        WHEN ID % 20 = 7 THEN 'Sofía'
        WHEN ID % 20 = 8 THEN 'Jorge'
        WHEN ID % 20 = 9 THEN 'Lucía'
        WHEN ID % 20 = 10 THEN 'Miguel'
        WHEN ID % 20 = 11 THEN 'Elena'
        WHEN ID % 20 = 12 THEN 'Pablo'
        WHEN ID % 20 = 13 THEN 'Carmen'
        WHEN ID % 20 = 14 THEN 'David'
        WHEN ID % 20 = 15 THEN 'Isabel'
        WHEN ID % 20 = 16 THEN 'Fernando'
        WHEN ID % 20 = 17 THEN 'Paula'
        WHEN ID % 20 = 18 THEN 'Javier'
        ELSE 'Teresa'
    END,
    -- Apellido paterno
    CASE 
        WHEN ID % 15 = 0 THEN 'García'
        WHEN ID % 15 = 1 THEN 'Rodríguez'
        WHEN ID % 15 = 2 THEN 'González'
        WHEN ID % 15 = 3 THEN 'Fernández'
        WHEN ID % 15 = 4 THEN 'López'
        WHEN ID % 15 = 5 THEN 'Martínez'
        WHEN ID % 15 = 6 THEN 'Sánchez'
        WHEN ID % 15 = 7 THEN 'Pérez'
        WHEN ID % 15 = 8 THEN 'Gómez'
        WHEN ID % 15 = 9 THEN 'Martín'
        WHEN ID % 15 = 10 THEN 'Jiménez'
        WHEN ID % 15 = 11 THEN 'Ruiz'
        WHEN ID % 15 = 12 THEN 'Hernández'
        WHEN ID % 15 = 13 THEN 'Díaz'
        ELSE 'Moreno'
    END,
    -- Apellido materno
    CASE 
        WHEN ID % 13 = 0 THEN 'López'
        WHEN ID % 13 = 1 THEN 'Martínez'
        WHEN ID % 13 = 2 THEN 'Sánchez'
        WHEN ID % 13 = 3 THEN 'Pérez'
        WHEN ID % 13 = 4 THEN 'Gómez'
        WHEN ID % 13 = 5 THEN 'Martín'
        WHEN ID % 13 = 6 THEN 'Jiménez'
        WHEN ID % 13 = 7 THEN 'Ruiz'
        WHEN ID % 13 = 8 THEN 'Hernández'
        WHEN ID % 13 = 9 THEN 'Díaz'
        WHEN ID % 13 = 10 THEN 'Moreno'
        WHEN ID % 13 = 11 THEN 'Álvarez'
        ELSE 'Muñoz'
    END,
    -- Fecha de nacimiento (entre 25 y 65 años atrás)
    DATEADD(YEAR, -25 - (ID % 40), DATEADD(DAY, ID % 365, DATEADD(MONTH, ID % 12, '2000-01-01'))),
    -- Género
    CASE WHEN ID % 2 = 0 THEN 'Masculino' ELSE 'Femenino' END,
    -- Estado civil (1-6)
    (ID % 6) + 1,
    -- Rol (1-12)
    (ID % 12) + 1,
    -- Departamento
    CASE 
        WHEN ID % 5 = 0 THEN 'Cardiología'
        WHEN ID % 5 = 1 THEN 'Emergencias'
        WHEN ID % 5 = 2 THEN 'Administración'
        WHEN ID % 5 = 3 THEN 'Pediatría'
        ELSE 'Laboratorio'
    END,
    -- Fecha contratación (últimos 10 años)
    DATEADD(DAY, - (ID % 1825), GETDATE()),
    -- Fecha salida (30% tienen fecha de salida)
    CASE 
        WHEN ID % 10 < 3 THEN DATEADD(DAY, (ID % 1825), DATEADD(DAY, - (ID % 1825), GETDATE()))
        ELSE NULL
    END,
    -- Nivel educación
    CASE 
        WHEN ID % 4 = 0 THEN 'Bachiller'
        WHEN ID % 4 = 1 THEN 'Licenciatura'
        WHEN ID % 4 = 2 THEN 'Maestría'
        ELSE 'Doctorado'
    END,
    -- Años experiencia (1-25)
    (ID % 25) + 1,
    -- Salario (2000-8000)
    2000 + (ID % 6000),
    -- Activo (si no tiene fecha de salida)
    CASE WHEN ID % 10 < 4 THEN 0 ELSE 1 END
FROM Numbers;

-- Insertar motivos_Salida
INSERT INTO MotivoSalida (
    Motivo_Salida_Id, Motivo, Categoria_Motivo, Subcategoria_Motivo,
    Es_Voluntario, Es_Evitable, Comentarios_Adicionales
)
VALUES 
-- Renuncias voluntarias
(1, 'Renuncia por mejores oportunidades', 'Renuncia Voluntaria', 'Oportunidad Profesional', 1, 1, 'Empleado encontró una mejor oferta laboral'),
(2, 'Renuncia por motivos personales', 'Renuncia Voluntaria', 'Personales', 1, 1, 'Motivos familiares o personales no especificados'),
(3, 'Renuncia por reubicación geográfica', 'Renuncia Voluntaria', 'Cambio de ciudad/país', 1, 1, 'Empleado se muda a otra ciudad'),
(4, 'Renuncia por estudios', 'Renuncia Voluntaria', 'Educación', 1, 1, 'Deja el empleo para continuar estudios'),
(5, 'Renuncia por estrés laboral', 'Renuncia Voluntaria', 'Salud Mental', 1, 1, 'Motivado por carga laboral o ambiente tenso'),

-- Terminaciones involuntarias
(6, 'Despido por bajo rendimiento', 'Despido Involuntario', 'Rendimiento', 0, 1, 'Empleado no cumplía con los objetivos establecidos'),
(7, 'Despido por faltas disciplinarias', 'Despido Involuntario', 'Disciplina', 0, 1, 'Incumplimiento de normas internas'),
(8, 'Despido por reducción de personal', 'Despido Involuntario', 'Reestructuración', 0, 0, 'Decisión empresarial por recorte de presupuesto'),
(9, 'Despido por cierre de área o proyecto', 'Despido Involuntario', 'Cierre de operaciones', 0, 0, 'Área eliminada por decisión corporativa'),
(10, 'Despido por ausentismo reiterado', 'Despido Involuntario', 'Asistencia', 0, 1, 'Faltas injustificadas constantes'),

-- Otros motivos
(11, 'Jubilación', 'Salida Natural', 'Edad de jubilación', 1, 0, 'Empleado alcanzó edad de jubilación'),
(12, 'Fallecimiento', 'Salida Involuntaria', 'Fallecimiento', 0, 0, 'Empleado falleció durante relación laboral'),
(13, 'Fin de contrato temporal', 'Fin de Contrato', 'Contrato vencido', 0, 0, 'No renovación de contrato a plazo fijo'),
(14, 'Licencia prolongada sin retorno', 'Salida Administrativa', 'Licencia sin retorno', 0, 1, 'Empleado no se reincorporó tras licencia'),
(15, 'Abandono de trabajo', 'Salida Involuntaria', 'Abandono', 0, 1, 'Empleado dejó de asistir sin aviso');

-- Registros de SalidasEmmpleados
-- truncate table Salidas_Empleados
WITH Numbers AS (
    SELECT TOP 1607 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Salidas_Empleados (
    ID_Salida,
    ID_Empleado,
    Fecha_Salida,
    ID_Motivo,
    Comentarios
)
SELECT
    ID,  -- ID_Salida
    ID,  -- ID_Empleado (asumiendo empleados del 1 al 8000)
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 2024, GETDATE()),  -- Fecha de salida en los últimos 5 años
    (ABS(CHECKSUM(NEWID())) % 15) + 1,  -- ID_Motivo entre 1 y 10
    CASE (ID % 15)
        WHEN 0 THEN 'Renuncia por motivos personales.'
        WHEN 1 THEN 'Despido por bajo rendimiento.'
        WHEN 2 THEN 'Fin de contrato temporal.'
        WHEN 3 THEN 'Salida voluntaria por oportunidad laboral.'
        WHEN 4 THEN 'Reubicación a otra ciudad.'
        WHEN 5 THEN 'Problemas de salud prolongados.'
        WHEN 6 THEN 'Jubilación.'
        WHEN 7 THEN 'Decisión estratégica de la empresa.'
        WHEN 8 THEN 'Salida por estudios superiores.'
		WHEN 9 THEN 'Despido por bajo rendimiento.'
        WHEN 10 THEN 'Fin de contrato temporal.'
        WHEN 11 THEN 'Salida voluntaria por oportunidad laboral.'
        WHEN 12 THEN 'Reubicación a otra ciudad.'
        WHEN 13 THEN 'Problemas de salud prolongados.'
        WHEN 14 THEN 'Jubilación.'
        ELSE 'Motivo de salida no especificado.'
    END
FROM Numbers;

------------------------------------------------------------------
-- Tabla Tipo_Servicio (8,000 registros)
------------------------------------------------------------------
-- truncate table Tipo_Servicio
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Tipo_Servicio (
    ID_Tipo_Servicio, 
    Nombre, 
    Descripcion, 
    Costo_Base
)
SELECT
    ID,
    -- Nombre del servicio (combinación de especialidad + tipo)
    CASE 
    WHEN ID % 20 BETWEEN 0 AND 4 THEN 'Consulta ' + 
        CASE ID % 5 
            WHEN 0 THEN 'General'
            WHEN 1 THEN 'de Medicina Interna'
            WHEN 2 THEN 'Pediátrica'
            WHEN 3 THEN 'Ginecológica'
            ELSE 'Geriátrica' 
        END

    WHEN ID % 20 BETWEEN 5 AND 7 THEN 'Examen ' + 
        CASE ID % 3 
            WHEN 0 THEN 'de Sangre'
            WHEN 1 THEN 'de Orina'
            ELSE 'de Imagen (Rayos X)' 
        END

    WHEN ID % 20 BETWEEN 8 AND 10 THEN 'Terapia ' + 
        CASE ID % 3 
            WHEN 0 THEN 'Física'
            WHEN 1 THEN 'Psicológica'
            ELSE 'Respiratoria' 
        END

    WHEN ID % 20 BETWEEN 11 AND 13 THEN 'Cirugía ' + 
        CASE ID % 3 
            WHEN 0 THEN 'Ambulatoria'
            WHEN 1 THEN 'Cardíaca'
            ELSE 'Plástica' 
        END

    WHEN ID % 20 BETWEEN 14 AND 15 THEN 'Procedimiento ' + 
        CASE ID % 2 
            WHEN 0 THEN 'Endoscópico'
            ELSE 'Quirúrgico Menor' 
        END

    WHEN ID % 20 = 16 THEN 'Hospitalización por Diagnóstico'

    WHEN ID % 20 = 17 THEN 'Consulta por Emergencia'

    WHEN ID % 20 = 18 THEN 'Servicio de Laboratorio Clínico'

    ELSE 'Atención Domiciliaria'
	END,
    -- Descripción (combinación aleatoria)
    CASE 
        WHEN ID % 10 = 0 THEN 'Procedimiento diagnóstico no invasivo'
        WHEN ID % 10 = 1 THEN 'Evaluación especializada por profesional certificado'
        WHEN ID % 10 = 2 THEN 'Tratamiento terapéutico ambulatorio'
        WHEN ID % 10 = 3 THEN 'Intervención quirúrgica con anestesia'
        WHEN ID % 10 = 4 THEN 'Estudio de laboratorio clínico'
        WHEN ID % 10 = 5 THEN 'Terapia de rehabilitación física'
        WHEN ID % 10 = 6 THEN 'Servicio de emergencia 24/7'
        WHEN ID % 10 = 7 THEN 'Consulta preventiva y de seguimiento'
        WHEN ID % 10 = 8 THEN 'Procedimiento con equipo especializado'
        ELSE 'Servicio médico integral multidisciplinario'
    END + ' - ' +
    CASE 
        WHEN ID % 8 = 0 THEN 'Requiere cita previa'
        WHEN ID % 8 = 1 THEN 'Disponible en horario extendido'
        WHEN ID % 8 = 2 THEN 'Con informe detallado'
        WHEN ID % 8 = 3 THEN 'Incluye materiales básicos'
        WHEN ID % 8 = 4 THEN 'Con seguimiento incluido'
        WHEN ID % 8 = 5 THEN 'Realizado por especialistas'
        WHEN ID % 8 = 6 THEN 'Con resultados inmediatos'
        ELSE 'Con opción de financiamiento'
    END,
    -- Costo base (entre $50 y $5,000 con incrementos de $10)
    CAST(50 + ((ID % 496) * 10) AS DECIMAL(10,2))
FROM Numbers;

------------------------------------------------------------------
-- Tabla ServiciosPrestados (8,000 registros)
------------------------------------------------------------------
-- truncate table ServiciosPrestados
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO ServiciosPrestados (
    ID_Tipo_Servicio, ID_Paciente, ID_Empleado,
    Fecha_Inicio, Fecha_Fin, Estado,
    Costo_Real, Observaciones
)
SELECT
    -- Tipo servicio (1-8)
    (ID % 8) + 1,
    -- ID Paciente (1-8000)
    (ID % 8000) + 1,
    -- ID Empleado (1-8000)
    (ID % 8000) + 1,
    -- Fecha inicio (últimos 5 años)
    DATEADD(DAY, - (ID % 1825), GETDATE()),
    -- Fecha fin (90% tienen fecha fin)
    CASE 
        WHEN ID % 10 = 0 THEN NULL
        ELSE DATEADD(HOUR, (ID % 72), DATEADD(DAY, - (ID % 1095), GETDATE()))
    END,
    -- Estado
    CASE 
        WHEN ID % 10 = 0 THEN 'Pendiente'
        WHEN ID % 10 = 1 THEN 'En progreso'
        WHEN ID % 10 = 2 THEN 'Cancelado'
        ELSE 'Completado'
    END,
    -- Costo real (variación del costo base)
    CASE 
        WHEN ID % 8 = 0 THEN 150.00 + (ID % 200)
        WHEN ID % 8 = 1 THEN 200.00 + (ID % 300)
        WHEN ID % 8 = 2 THEN 500.00 + (ID % 500)
        WHEN ID % 8 = 3 THEN 300.00 + (ID % 400)
        WHEN ID % 8 = 4 THEN 1000.00 + (ID % 800)
        WHEN ID % 8 = 5 THEN 1500.00 + (ID % 1000)
        WHEN ID % 8 = 6 THEN 120.00 + (ID % 150)
        ELSE 180.00 + (ID % 200)
    END,
    -- Observaciones
    CASE 
        WHEN ID % 5 = 0 THEN 'Paciente puntual'
        WHEN ID % 5 = 1 THEN 'Requiere seguimiento'
        WHEN ID % 5 = 2 THEN 'Derivado a especialista'
        WHEN ID % 5 = 3 THEN 'Alergias conocidas'
        ELSE 'Sin observaciones'
    END
FROM Numbers;
USE BD_AUNA;
GO

------------------------------------------------------------------
-- Tabla categorías básicas de productos (8,000 registros)
------------------------------------------------------------------
INSERT INTO Categorias_Producto (ID_Categoria, Nombre, Descripcion) VALUES
(1, 'Medicamentos', 'Productos farmacéuticos para tratamiento de enfermedades'),
(2, 'Material de Curación', 'Insumos para curaciones y procedimientos médicos'),
(3, 'Equipo Médico', 'Instrumentos y dispositivos para diagnóstico y tratamiento'),
(4, 'Productos de Higiene', 'Artículos para aseo y limpieza del paciente'),
(5, 'Insumos Hospitalarios', 'Material desechable para uso clínico'),
(6, 'Equipo de Protección', 'Elementos de bioseguridad para personal médico'),
(7, 'Suplementos Nutricionales', 'Complementos alimenticios y vitamínicos'),
(8, 'Productos para Laboratorio', 'Reactivos y materiales para análisis clínicos'),
(9, 'Ortopedia', 'Productos de apoyo y rehabilitación física'),
(10, 'Cuidado del Paciente', 'Artículos para comodidad y cuidado del paciente');

------------------------------------------------------------------
-- Tabla ProductosFarmaceuticos (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO ProductosFarmaceuticos (
    ID_Categoria, Nombre_Producto, Descripcion,
    Precio_Venta, Costo_Compra, Stock, Stock_Minimo, Activo
)
SELECT
    -- Categoría (1-4)
    (ID % 4) + 1,
    -- Nombre producto
    CASE 
        WHEN ID % 10 = 0 THEN 'Omeprazol 20mg'
        WHEN ID % 10 = 1 THEN 'Paracetamol 500mg'
        WHEN ID % 10 = 2 THEN 'Ibuprofeno 400mg'
        WHEN ID % 10 = 3 THEN 'Amoxicilina 500mg'
        WHEN ID % 10 = 4 THEN 'Loratadina 10mg'
        WHEN ID % 10 = 5 THEN 'Jarabe para la tos'
        WHEN ID % 10 = 6 THEN 'Gasas estériles'
        WHEN ID % 10 = 7 THEN 'Jeringas 5ml'
        WHEN ID % 10 = 8 THEN 'Guantes quirúrgicos'
        ELSE 'Termómetro digital'
    END,
    -- Descripción
    CASE 
        WHEN ID % 10 = 0 THEN 'Inhibidor de bomba de protones'
        WHEN ID % 10 = 1 THEN 'Analgésico y antipirético'
        WHEN ID % 10 = 2 THEN 'Antiinflamatorio no esteroideo'
        WHEN ID % 10 = 3 THEN 'Antibiótico de amplio espectro'
        WHEN ID % 10 = 4 THEN 'Antihistamínico'
        WHEN ID % 10 = 5 THEN 'Alivia la tos seca'
        WHEN ID % 10 = 6 THEN 'Paquete de 10 unidades'
        WHEN ID % 10 = 7 THEN 'Caja de 50 unidades'
        WHEN ID % 10 = 8 THEN 'Talla M, caja de 100'
        ELSE 'Precisión ±0.1°C'
    END,
    -- Precio venta (5-100)
    5 + (ID % 95),
    -- Costo compra (3-80)
    3 + (ID % 77),
    -- Stock (0-500)
    ID % 500,
    -- Stock mínimo (10-100)
    10 + (ID % 90),
    -- Activo (90% activos)
    CASE WHEN ID % 10 = 0 THEN 0 ELSE 1 END
FROM Numbers;

------------------------------------------------------------------
-- Tabla Ventas (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Ventas (
    ID_Venta, ID_Empleado, Fecha, Estado,
    Subtotal, Descuento, Total
)
SELECT
    ID,
    -- ID Empleado (1-8000)
    (ID % 8000) + 1,
    -- Fecha (últimos 2 años)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Estado
    CASE 
        WHEN ID % 5 = 0 THEN 'Pendiente'
        WHEN ID % 5 = 1 THEN 'Procesando'
        WHEN ID % 5 = 2 THEN 'Cancelada'
        ELSE 'Completada'
    END,
    -- Subtotal (50-1000)
    50 + (ID % 950),
    -- Descuento (0-20%)
    (ID % 20),
    -- Total (subtotal - descuento)
    50 + (ID % 950) - (50 + (ID % 950)) * (ID % 20) / 100
FROM Numbers;

------------------------------------------------------------------
-- Tabla Detalles_Venta (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Detalles_Venta (
    ID_Detalle_Venta, ID_Venta, ID_ProductoFarmaceutico,
    Cantidad, Precio_Unitario, Descuento, Subtotal
)
SELECT
    ID,
    -- ID Venta (1-8000)
    (ID % 8000) + 1,
    -- ID_ProductoFarmaceutico (1-8000)
    (ID % 8000) + 1,
    -- Cantidad (1-10)
    (ID % 10) + 1,
    -- Precio unitario (5-100)
    5 + (ID % 95),
    -- Descuento (0-20%)
    (ID % 20),
    -- Subtotal (cantidad * precio unitario - descuento)
    ((ID % 10) + 1) * (5 + (ID % 95)) - (((ID % 10) + 1) * (5 + (ID % 95)) * (ID % 20) / 100)
FROM Numbers;

------------------------------------------------------------------
-- Tabla Facturacion (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Facturacion (
    ID_Factura, ID_Paciente, ID_Venta, ID_ServicioPrestado,
    Fecha, Descripcion, Subtotal, Impuestos, Total, Estado
)
SELECT
    ID,
    -- ID Paciente (1-8000)
    (ID % 8000) + 1,
    -- ID Venta (1-8000, 50% nulos)
    CASE WHEN ID % 2 = 0 THEN (ID % 8000) + 1 ELSE NULL END,
    -- ID ServicioPrestado (1-8000, 50% nulos)
    CASE WHEN ID % 2 = 1 THEN (ID % 8000) + 1 ELSE NULL END,
    -- Fecha (últimos 2 años)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Descripción
    CASE 
        WHEN ID % 5 = 0 THEN 'Consulta médica'
        WHEN ID % 5 = 1 THEN 'Exámenes de laboratorio'
        WHEN ID % 5 = 2 THEN 'Medicamentos'
        WHEN ID % 5 = 3 THEN 'Hospitalización'
        ELSE 'Procedimiento médico'
    END,
    -- Subtotal (50-2000)
    50 + (ID % 1950),
    -- Impuestos (18% del subtotal)
    (50 + (ID % 1950)) * 0.18,
    -- Total (subtotal + impuestos)
    (50 + (ID % 1950)) * 1.18,
    -- Estado
    CASE 
        WHEN ID % 4 = 0 THEN 'Pendiente'
        WHEN ID % 4 = 1 THEN 'Pagada'
        WHEN ID % 4 = 2 THEN 'Anulada'
        ELSE 'En proceso'
    END
FROM Numbers;

------------------------------------------------------------------
-- Tabla Pagos (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Pagos (
    ID_Pago, ID_Factura, Fecha, Monto,
    Metodo_Pago, Estado, Referencia
)
SELECT
    ID,
    -- ID Factura (1-8000)
    (ID % 8000) + 1,
    -- Fecha (últimos 2 años)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Monto (50-2000)
    50 + (ID % 1950),
    -- Método de pago
    CASE 
        WHEN ID % 5 = 0 THEN 'Efectivo'
        WHEN ID % 5 = 1 THEN 'Tarjeta de crédito'
        WHEN ID % 5 = 2 THEN 'Tarjeta de débito'
        WHEN ID % 5 = 3 THEN 'Transferencia'
        ELSE 'Cheque'
    END,
    -- Estado
    CASE 
        WHEN ID % 3 = 0 THEN 'Pendiente'
        WHEN ID % 3 = 1 THEN 'Completado'
        ELSE 'Rechazado'
    END,
    -- Referencia
    'REF-' + RIGHT('00000000' + CAST(ID AS VARCHAR), 8)
FROM Numbers;
USE BD_AUNA;
GO

------------------------------------------------------------------
-- Tabla Equipos medicos
------------------------------------------------------------------
INSERT INTO Equipos_Medicos (ID_EquipoMedico, Nombre, Tipo, Fecha_Compra, Estado, Ubicacion, Vida_Util, Costo_Adquisicion) VALUES
-- Equipos de Diagnóstico (1-10)
(1, 'Electrocardiógrafo', 'Diagnóstico Cardíaco', '2022-01-15', 'Activo', 'Consultorio 1', 7, 8500.00),
(2, 'Ecógrafo Portátil', 'Diagnóstico por Imágenes', '2021-11-20', 'Activo', 'Sala de Emergencias', 5, 12000.00),
(3, 'Monitor de Signos Vitales', 'Monitoreo', '2023-03-10', 'Activo', 'Quirófano 1', 6, 6500.00),
(4, 'Máquina de Anestesia', 'Anestesiología', '2020-09-05', 'En Mantenimiento', 'Quirófano 2', 8, 18500.00),
(5, 'Resonador Magnético', 'Diagnóstico por Imágenes', '2022-06-18', 'Activo', 'Área de Imágenes', 10, 350000.00),
(6, 'Tomógrafo Computarizado', 'Diagnóstico por Imágenes', '2021-12-12', 'Activo', 'Área de Imágenes', 10, 280000.00),
(7, 'Mamógrafo Digital', 'Diagnóstico Mamario', '2023-01-30', 'Activo', 'Área de Imágenes', 7, 95000.00),
(8, 'Densitómetro Óseo', 'Diagnóstico Óseo', '2022-08-22', 'Activo', 'Laboratorio', 8, 45000.00),
(9, 'Espirómetro', 'Diagnóstico Respiratorio', '2023-02-15', 'Activo', 'Consultorio 2', 5, 3200.00),
(10, 'Otoscopio Digital', 'Diagnóstico Otorrino', '2023-04-05', 'Activo', 'Consultorio 3', 4, 2800.00),
-- Equipos de Laboratorio (11-20)
(11, 'Analizador Hematológico', 'Laboratorio', '2021-10-10', 'Activo', 'Laboratorio Central', 6, 42000.00),
(12, 'Centrífuga', 'Laboratorio', '2022-05-12', 'Activo', 'Laboratorio Central', 5, 5800.00),
(13, 'Microscopio Electrónico', 'Laboratorio', '2020-12-15', 'En Reparación', 'Laboratorio Investigación', 8, 75000.00),
(14, 'Autoclave', 'Esterilización', '2023-01-20', 'Activo', 'Área de Esterilización', 7, 12500.00),
(15, 'Baño María', 'Laboratorio', '2022-09-08', 'Activo', 'Laboratorio Central', 5, 3200.00),
(16, 'Contador Hematológico', 'Laboratorio', '2021-07-30', 'Activo', 'Laboratorio Central', 6, 38000.00),
(17, 'Incubadora', 'Laboratorio', '2023-03-15', 'Activo', 'Laboratorio Microbiología', 6, 9500.00),
(18, 'Refrigerador de Sangre', 'Laboratorio', '2022-11-10', 'Activo', 'Banco de Sangre', 7, 8200.00),
(19, 'Analizador de Orina', 'Laboratorio', '2022-04-18', 'Activo', 'Laboratorio Central', 5, 18500.00),
(20, 'Agitador Vortex', 'Laboratorio', '2023-05-01', 'Activo', 'Laboratorio Central', 4, 1200.00),
-- Equipos de Tratamiento (21-30)
(21, 'Desfibrilador', 'Emergencias', '2022-02-28', 'Activo', 'Sala de Emergencias', 6, 9800.00),
(22, 'Bomba de Infusión', 'Tratamiento', '2023-01-10', 'Activo', 'Hospitalización', 5, 3200.00),
(23, 'Ventilador Mecánico', 'Terapia Respiratoria', '2021-09-15', 'Activo', 'UCI', 7, 28500.00),
(24, 'Láser Médico', 'Dermatología', '2022-07-20', 'Activo', 'Consultorio Dermatología', 6, 42000.00),
(25, 'Equipo de Diálisis', 'Nefrología', '2020-11-05', 'En Mantenimiento', 'Área de Diálisis', 8, 120000.00),
(26, 'Unidad de Electrocirugía', 'Quirúrgico', '2023-02-12', 'Activo', 'Quirófano 1', 7, 18500.00),
(27, 'Cámara Hiperbárica', 'Medicina Hiperbárica', '2021-12-10', 'Activo', 'Área de Terapias', 10, 95000.00),
(28, 'Equipo de Rayos Láser', 'Oftalmología', '2022-10-15', 'Activo', 'Consultorio Oftalmología', 8, 65000.00),
(29, 'Unidad de Crioterapia', 'Dermatología', '2023-03-25', 'Activo', 'Consultorio Dermatología', 6, 28000.00),
(30, 'Equipo de Fisioterapia', 'Rehabilitación', '2022-06-10', 'Activo', 'Área de Fisioterapia', 7, 32000.00),
-- Equipos de Soporte (31-40)
(31, 'Carro de Emergencias', 'Emergencias', '2023-01-15', 'Activo', 'Sala de Emergencias', 5, 4500.00),
(32, 'Cama Hospitalaria', 'Hospitalización', '2022-08-20', 'Activo', 'Piso 2 - Habitación 201', 8, 2800.00),
(33, 'Mesa Quirúrgica', 'Quirúrgico', '2021-05-12', 'Activo', 'Quirófano 1', 10, 18500.00),
(34, 'Lámpara Quirúrgica', 'Quirúrgico', '2022-11-30', 'Activo', 'Quirófano 2', 7, 9500.00),
(35, 'Estación de Enfermería', 'Monitoreo', '2023-02-18', 'Activo', 'Hospitalización', 6, 6500.00),
(36, 'Silla de Ruedas', 'Movilidad', '2022-09-10', 'Activo', 'Entrada Principal', 4, 850.00),
(37, 'Camilla de Transporte', 'Movilidad', '2023-04-05', 'Activo', 'Sala de Emergencias', 5, 1200.00),
(38, 'Estetoscopio Electrónico', 'Diagnóstico', '2023-03-15', 'Activo', 'Consultorio 1', 4, 650.00),
(39, 'Nebulizador', 'Terapia Respiratoria', '2022-12-10', 'Activo', 'Consultorio Neumología', 5, 980.00),
(40, 'Oxímetro de Pulso', 'Monitoreo', '2023-05-20', 'Activo', 'Hospitalización', 4, 450.00);

------------------------------------------------------------------
-- Tabla Tipos de Gastos (8,000 registros)
------------------------------------------------------------------
INSERT INTO Tipo_Gasto (ID_Tipo_Gasto, Nombre, Descripcion, Categoria) VALUES
-- Costos Directos (1-10)
(1, 'Materiales Médicos', 'Compra de insumos médicos descartables', 'Directo'),
(2, 'Medicamentos', 'Adquisición de fármacos para farmacia', 'Directo'),
(3, 'Salario Médico', 'Honorarios de profesionales médicos', 'Directo'),
(4, 'Equipos Médicos', 'Compra de equipos para diagnóstico/t tratamiento', 'Directo'),
(5, 'Suministros Clínicos', 'Material de curación y procedimientos', 'Directo'),
(6, 'Honorarios Profesionales', 'Pago a especialistas externos', 'Directo'),
(7, 'Reactivos Laboratorio', 'Insumos para análisis clínicos', 'Directo'),
(8, 'Material Quirúrgico', 'Insumos para salas de operaciones', 'Directo'),
(9, 'Prótesis e Implantes', 'Materiales para cirugías', 'Directo'),
(10, 'Ayudas Diagnósticas', 'Estudios externos para pacientes', 'Directo'),
-- Costos Indirectos (11-20)
(11, 'Administración', 'Gastos de personal administrativo', 'Indirecto'),
(12, 'Limpieza', 'Servicios de aseo y mantenimiento', 'Indirecto'),
(13, 'Servicios Públicos', 'Agua, luz, gas, telecomunicaciones', 'Indirecto'),
(14, 'Seguros', 'Pólizas de seguro de la clínica', 'Indirecto'),
(15, 'Capacitación', 'Entrenamiento para el personal', 'Indirecto'),
(16, 'Sistemas', 'Mantenimiento de software administrativo', 'Indirecto'),
(17, 'Gastos Legales', 'Honorarios de abogados y trámites', 'Indirecto'),
(18, 'Papelería', 'Material de oficina y formularios', 'Indirecto'),
(19, 'Mantenimiento', 'Reparaciones generales', 'Indirecto'),
(20, 'Utilitarios', 'Gastos varios de operación', 'Indirecto'),
-- Costos de Tecnología (21-25)
(21, 'Software Médico', 'Licencias de sistemas clínicos', 'Tecnología'),
(22, 'Hardware', 'Equipos de computación y redes', 'Tecnología'),
(23, 'Mantenimiento TI', 'Soporte técnico especializado', 'Tecnología'),
(24, 'Servicios en Nube', 'Almacenamiento y backups', 'Tecnología'),
(25, 'Ciberseguridad', 'Protección de datos y sistemas', 'Tecnología'),
-- Costos de Marketing (26-30)
(26, 'Publicidad Digital', 'Campañas en redes y buscadores', 'Marketing'),
(27, 'Material Promocional', 'Folletos y banners', 'Marketing'),
(28, 'Eventos Médicos', 'Participación en congresos', 'Marketing'),
(29, 'Diseño Gráfico', 'Creación de material visual', 'Marketing'),
(30, 'Estudios de Mercado', 'Investigación de pacientes', 'Marketing'),
-- Costos de Infraestructura (31-35)
(31, 'Remodelaciones', 'Adecuación de espacios clínicos', 'Infraestructura'),
(32, 'Mobiliario', 'Compra de camas y equipamiento', 'Infraestructura'),
(33, 'Equipos Clínicos', 'Maquinaria pesada para hospitalización', 'Infraestructura'),
(34, 'Sistemas Eléctricos', 'Mejoras en instalaciones', 'Infraestructura'),
(35, 'Adecuaciones Especiales', 'Salas limpias y quirófanos', 'Infraestructura'),
-- Otros gastos (36-40)
(36, 'Amortizaciones', 'Depreciación de activos fijos', 'Financiero'),
(37, 'Intereses', 'Pagos por financiamientos', 'Financiero'),
(38, 'Impuestos', 'Pago de obligaciones tributarias', 'Financiero'),
(39, 'Donaciones', 'Ayudas sociales comunitarias', 'Social'),
(40, 'Contingencias', 'Fondo para imprevistos', 'Administrativo');

------------------------------------------------------------------
-- Tabla Gastos (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Gastos (
    ID_Gasto, ID_Tipo_Gasto, Fecha,
    Descripcion, Monto, ID_Empleado_Responsable,
    ID_EquipoMedico, ID_ProductoFarmaceutico
)
SELECT
    ID,
    -- ID Tipo Gasto (1-40)
    (ID % 40) + 1,
    -- Fecha (últimos 2 años)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Descripción
    CASE 
        WHEN ID % 7 = 0 THEN 'Compra de medicamentos'
        WHEN ID % 7 = 1 THEN 'Mantenimiento de equipos'
        WHEN ID % 7 = 2 THEN 'Pago de servicios básicos'
        WHEN ID % 7 = 3 THEN 'Capacitación del personal'
        WHEN ID % 7 = 4 THEN 'Publicidad y marketing'
        WHEN ID % 7 = 5 THEN 'Reparaciones de infraestructura'
        ELSE 'Adquisición de nuevos equipos'
    END,
    -- Monto (100-10000)
    100 + (ID % 9900),
    -- ID Empleado Responsable (1-8000)
    (ID % 8000) + 1,
    -- ID Equipo (1-40, 70% nulos)
    CASE WHEN ID % 10 < 3 THEN (ID % 40) + 1 ELSE NULL END,
    -- ID_ProductoFarmaceutico (1-8000, 70% nulos)
    CASE WHEN ID % 10 < 3 THEN (ID % 40) + 1 ELSE NULL END
FROM Numbers;

-- truncate table Encuestas_Satisfaccion
------------------------------------------------------------------
-- Tabla Encuestas_Satisfaccion (8,000 registros)
------------------------------------------------------------------
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Encuestas_Satisfaccion (
    ID_Encuesta, ID_Paciente, Fecha_Encuesta,
    Puntaje_Calidad_Atencion, Puntaje_Tiempo_Espera,
    Puntaje_Empleado, Puntaje_Infraestructura,
    Puntaje_Comunicacion, Puntaje_NPS, Comentario
)
SELECT
    ID,
    -- ID Paciente (1-8000)
    (ID % 8000) + 1,
    -- Fecha (últimos 5 años)
    DATEADD(DAY, - (ID % 1825), GETDATE()),
    
    -- Puntajes (0-10) con tendencia a 8 y 9
    
    -- Atencion
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 15 THEN 10   -- 15% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 35 THEN 9    -- 20% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 60 THEN 8    -- 25% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 75 THEN 7    -- 15% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 85 THEN 6    -- 10% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 92 THEN 5    -- 7% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 96 THEN 4    -- 4% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 98 THEN 3    -- 2% probabilidad
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 99 THEN 2    -- 1% probabilidad
        ELSE 1                                           -- 1% probabilidad
    END,

    -- Tiempo espera
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 10 THEN 10
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 30 THEN 9
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 55 THEN 8
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 75 THEN 7
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 85 THEN 6
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 92 THEN 5
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 96 THEN 4
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 98 THEN 3
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 99 THEN 2
        ELSE 1
    END,

    -- Empleados
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 12 THEN 10
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 32 THEN 9
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 57 THEN 8
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 72 THEN 7
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 82 THEN 6
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 89 THEN 5
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 94 THEN 4
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 97 THEN 3
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 99 THEN 2
        ELSE 1
    END,

    -- Infraestructura (versión corregida)
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 65 THEN -- 65% de probabilidad para 7-9
            CASE 
                WHEN ABS(CHECKSUM(NEWID()) % 3) = 0 THEN 7
                WHEN ABS(CHECKSUM(NEWID()) % 3) = 1 THEN 8
                ELSE 9
            END
        ELSE -- 35% de probabilidad para 0-6
            ABS(CHECKSUM(NEWID()) % 7)
    END,

    -- Comunicacion
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 10 THEN 10
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 25 THEN 9
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 50 THEN 8
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 70 THEN 7
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 85 THEN 6
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 92 THEN 5
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 96 THEN 4
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 98 THEN 3
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 99 THEN 2
        ELSE 1
    END,

    -- NPS
    CASE 
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 5 THEN 10    -- Promotores (5%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 15 THEN 9    -- (10%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 35 THEN 8    -- (20%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 55 THEN 7    -- (20%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 70 THEN 6    -- (15%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 80 THEN 5    -- (10%) Neutrales
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 87 THEN 4    -- (7%)
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 93 THEN 3    -- (6%) Detractores
        WHEN ABS(CHECKSUM(NEWID()) % 100) < 97 THEN 2    -- (4%)
        ELSE 1                                           -- (3%)
    END,
    
    -- Comentario
    CASE 
        WHEN ID % 5 = 0 THEN 'Excelente atención'
        WHEN ID % 5 = 1 THEN 'Podría mejorar'
        WHEN ID % 5 = 2 THEN 'Tiempo de espera muy largo'
        WHEN ID % 5 = 3 THEN 'Personal muy amable'
        ELSE 'Instalaciones limpias y modernas'
    END
FROM Numbers;


/*Ver promedio
SELECT 
    AVG([Puntaje_Infraestructura]) AS PromedioPI,
	AVG([Puntaje_Calidad_Atencion]) AS PromedioCA,
	AVG([Puntaje_Empleado]) AS PromedioE,
	AVG([Puntaje_Tiempo_Espera]) AS PromedioTE,
	AVG([Puntaje_Comunicacion]) AS PromedioC,
	AVG([Puntaje_NPS]) AS PromedioNPS
FROM 
    Encuestas_Satisfaccion
*/
------------------------------------------------------------------
-- Tabla Reclamos (8,000 registros)
------------------------------------------------------------------
--TRUNCATE TABLE Reclamos
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Reclamos (
    ID_Reclamo, ID_Paciente, Fecha_Reclamo,
    Tipo_Reclamo, Descripcion, ID_Empleado_Asignado,
    Respuesta, Fecha_Respuesta, Estado
)
SELECT
    ID,
    -- ID Paciente (1-8000)
    (ID % 8000) + 1,
    -- Fecha (últimos 5 años)
    DATEADD(DAY, - (ID % 2024), GETDATE()),
    -- Tipo Reclamo
    CASE 
        WHEN ID % 5 = 0 THEN 'Atención médica'
        WHEN ID % 5 = 1 THEN 'Tiempo de espera'
        WHEN ID % 5 = 2 THEN 'Facturación'
        WHEN ID % 5 = 3 THEN 'Limpieza'
        ELSE 'Trato del personal'
    END,
    -- Descripción
    CASE 
        WHEN ID % 5 = 0 THEN 'El médico no fue claro en el diagnóstico'
        WHEN ID % 5 = 1 THEN 'Esperé más de 2 horas para ser atendido'
        WHEN ID % 5 = 2 THEN 'Error en la factura de mi consulta'
        WHEN ID % 5 = 3 THEN 'El baño estaba sucio durante mi visita'
        ELSE 'Recepcionista fue grosero conmigo'
    END,
    -- ID Empleado Asignado (1-8000, 80% no nulos)
    CASE WHEN ID % 5 = 0 THEN NULL ELSE (ID % 8000) + 1 END,
    -- Respuesta
    CASE 
        WHEN ID % 5 = 0 THEN 'Hablaremos con el profesional para mejorar la comunicación'
        WHEN ID % 5 = 1 THEN 'Lamentamos la demora. Estamos contratando más personal'
        WHEN ID % 5 = 2 THEN 'Hemos corregido el error y enviado nueva factura'
        WHEN ID % 5 = 3 THEN 'Hemos reforzado el protocolo de limpieza'
        ELSE 'El empleado recibió capacitación adicional'
    END,
    -- Fecha Respuesta (80% tienen fecha)
    CASE WHEN ID % 5 = 0 THEN NULL ELSE DATEADD(DAY, 1 + (ID % 14), DATEADD(DAY, - (ID % 2024), GETDATE())) END,
    -- Estado
    CASE 
        WHEN ID % 3 = 0 THEN 'Pendiente'
        WHEN ID % 3 = 1 THEN 'Resuelto'
        ELSE 'En proceso'
    END
FROM Numbers;

------------------------------------------------------------------
-- Registros para tabla Calificaciones_Online (8,000 registros)
------------------------------------------------------------------
--truncate table Calificaciones_Online
WITH Numbers AS (
    SELECT TOP 8000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Calificaciones_Online (
    ID_Calificacion, ID_Paciente, Fecha_Calificacion,
    Plataforma, Puntaje, Comentario,
    Respuesta, Fecha_Respuesta
)
SELECT
    ID,
    -- ID Paciente (1-8000)
    (ID % 8000) + 1,
    -- Fecha (últimos 2 años)
    DATEADD(DAY, - (ID % 1200), GETDATE()),
    -- Plataforma
    CASE 
        WHEN ID % 3 = 0 THEN 'App Móvil'
        WHEN ID % 3 = 1 THEN 'Sitio Web'
        ELSE 'Portal Pacientes'
    END,
    -- Puntaje (1-5)
    (ID % 5) + 1,
    -- Comentario
    CASE 
        WHEN ID % 5 = 0 THEN 'Muy fácil de usar, excelente experiencia'
        WHEN ID % 5 = 1 THEN 'La aplicación se cierra frecuentemente'
        WHEN ID % 5 = 2 THEN 'Podrían mejorar el diseño de la interfaz'
        WHEN ID % 5 = 3 THEN 'No puedo acceder a mis resultados médicos'
        ELSE 'Funciona perfectamente, muy satisfecho'
    END,
    -- Respuesta
    CASE 
        WHEN ID % 5 = 0 THEN '¡Gracias por tu feedback positivo!'
        WHEN ID % 5 = 1 THEN 'Estamos trabajando en la estabilidad de la app'
        WHEN ID % 5 = 2 THEN 'Tenemos planeado un rediseño para el próximo trimestre'
        WHEN ID % 5 = 3 THEN 'Por favor contáctenos para ayudarte con este problema'
        ELSE 'Nos alegra que tengas buena experiencia con nuestra plataforma'
    END,
	-- Fecha Respuesta (100% con fecha)
	DATEADD(DAY, 1 + (ID % 7), DATEADD(DAY, - (ID % 600), GETDATE()))
    /*-- Fecha Respuesta (60% tienen fecha)
    CASE WHEN ID % 5 < 3 THEN NULL ELSE DATEADD(DAY, 1 + (ID % 7), DATEADD(DAY, - (ID % 730), GETDATE())) END*/
FROM Numbers;