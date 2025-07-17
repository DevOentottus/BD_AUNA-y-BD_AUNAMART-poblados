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
        WHEN ID % 20 = 1 THEN 'Mar�a'
        WHEN ID % 20 = 2 THEN 'Carlos'
        WHEN ID % 20 = 3 THEN 'Ana'
        WHEN ID % 20 = 4 THEN 'Luis'
        WHEN ID % 20 = 5 THEN 'Laura'
        WHEN ID % 20 = 6 THEN 'Pedro'
        WHEN ID % 20 = 7 THEN 'Sof�a'
        WHEN ID % 20 = 8 THEN 'Jorge'
        WHEN ID % 20 = 9 THEN 'Luc�a'
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
        WHEN ID % 15 = 0 THEN 'Garc�a'
        WHEN ID % 15 = 1 THEN 'Rodr�guez'
        WHEN ID % 15 = 2 THEN 'Gonz�lez'
        WHEN ID % 15 = 3 THEN 'Fern�ndez'
        WHEN ID % 15 = 4 THEN 'L�pez'
        WHEN ID % 15 = 5 THEN 'Mart�nez'
        WHEN ID % 15 = 6 THEN 'S�nchez'
        WHEN ID % 15 = 7 THEN 'P�rez'
        WHEN ID % 15 = 8 THEN 'G�mez'
        WHEN ID % 15 = 9 THEN 'Mart�n'
        WHEN ID % 15 = 10 THEN 'Jim�nez'
        WHEN ID % 15 = 11 THEN 'Ruiz'
        WHEN ID % 15 = 12 THEN 'Hern�ndez'
        WHEN ID % 15 = 13 THEN 'D�az'
        ELSE 'Moreno'
    END,
    -- DNI �nico (8 d�gitos)
    RIGHT('00000000' + CAST(10000000 + ID AS VARCHAR), 8),
    -- Fecha de nacimiento (entre 18 y 90 a�os atr�s)
    DATEADD(YEAR, -18 - (ID % 72), DATEADD(DAY, ID % 365, DATEADD(MONTH, ID % 12, '2000-01-01'))),
    -- Sexo
    CASE WHEN ID % 2 = 0 THEN 'M' ELSE 'F' END,
    -- Tel�fono (9 d�gitos)
    CASE WHEN ID = 0 THEN NULL ELSE '9' + RIGHT('00000000' + CAST(10000000 + (ID * 7) % 90000000 AS VARCHAR), 8) END,
    -- Correo electr�nico
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
    -- Direcci�n
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
    -- Fecha de registro (�ltimos 5 a�os)
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
(5, 'Uni�n Libre'),
(6, 'Separado');
COMMIT TRANSACTION;
GO

------------------------------------------------------------------
--			   Insertar registros Tabla Rol   					--
------------------------------------------------------------------
BEGIN TRANSACTION;
INSERT INTO Rol (Rol_Id, Nombre_Rol) VALUES
(1, 'M�dico General'),
(2, 'Enfermero/a'),
(3, 'Recepcionista'),
(4, 'Administrador/a Cl�nico'),
(5, 'T�cnico de Laboratorio'),
(6, 'Cirujano/a'),
(7, 'Pediatra'),
(8, 'Radi�logo/a'),
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
        WHEN ID % 20 = 1 THEN 'Mar�a'
        WHEN ID % 20 = 2 THEN 'Carlos'
        WHEN ID % 20 = 3 THEN 'Ana'
        WHEN ID % 20 = 4 THEN 'Luis'
        WHEN ID % 20 = 5 THEN 'Laura'
        WHEN ID % 20 = 6 THEN 'Pedro'
        WHEN ID % 20 = 7 THEN 'Sof�a'
        WHEN ID % 20 = 8 THEN 'Jorge'
        WHEN ID % 20 = 9 THEN 'Luc�a'
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
        WHEN ID % 15 = 0 THEN 'Garc�a'
        WHEN ID % 15 = 1 THEN 'Rodr�guez'
        WHEN ID % 15 = 2 THEN 'Gonz�lez'
        WHEN ID % 15 = 3 THEN 'Fern�ndez'
        WHEN ID % 15 = 4 THEN 'L�pez'
        WHEN ID % 15 = 5 THEN 'Mart�nez'
        WHEN ID % 15 = 6 THEN 'S�nchez'
        WHEN ID % 15 = 7 THEN 'P�rez'
        WHEN ID % 15 = 8 THEN 'G�mez'
        WHEN ID % 15 = 9 THEN 'Mart�n'
        WHEN ID % 15 = 10 THEN 'Jim�nez'
        WHEN ID % 15 = 11 THEN 'Ruiz'
        WHEN ID % 15 = 12 THEN 'Hern�ndez'
        WHEN ID % 15 = 13 THEN 'D�az'
        ELSE 'Moreno'
    END,
    -- Apellido materno
    CASE 
        WHEN ID % 13 = 0 THEN 'L�pez'
        WHEN ID % 13 = 1 THEN 'Mart�nez'
        WHEN ID % 13 = 2 THEN 'S�nchez'
        WHEN ID % 13 = 3 THEN 'P�rez'
        WHEN ID % 13 = 4 THEN 'G�mez'
        WHEN ID % 13 = 5 THEN 'Mart�n'
        WHEN ID % 13 = 6 THEN 'Jim�nez'
        WHEN ID % 13 = 7 THEN 'Ruiz'
        WHEN ID % 13 = 8 THEN 'Hern�ndez'
        WHEN ID % 13 = 9 THEN 'D�az'
        WHEN ID % 13 = 10 THEN 'Moreno'
        WHEN ID % 13 = 11 THEN '�lvarez'
        ELSE 'Mu�oz'
    END,
    -- Fecha de nacimiento (entre 25 y 65 a�os atr�s)
    DATEADD(YEAR, -25 - (ID % 40), DATEADD(DAY, ID % 365, DATEADD(MONTH, ID % 12, '2000-01-01'))),
    -- G�nero
    CASE WHEN ID % 2 = 0 THEN 'Masculino' ELSE 'Femenino' END,
    -- Estado civil (1-6)
    (ID % 6) + 1,
    -- Rol (1-12)
    (ID % 12) + 1,
    -- Departamento
    CASE 
        WHEN ID % 5 = 0 THEN 'Cardiolog�a'
        WHEN ID % 5 = 1 THEN 'Emergencias'
        WHEN ID % 5 = 2 THEN 'Administraci�n'
        WHEN ID % 5 = 3 THEN 'Pediatr�a'
        ELSE 'Laboratorio'
    END,
    -- Fecha contrataci�n (�ltimos 10 a�os)
    DATEADD(DAY, - (ID % 1825), GETDATE()),
    -- Fecha salida (30% tienen fecha de salida)
    CASE 
        WHEN ID % 10 < 3 THEN DATEADD(DAY, (ID % 1825), DATEADD(DAY, - (ID % 1825), GETDATE()))
        ELSE NULL
    END,
    -- Nivel educaci�n
    CASE 
        WHEN ID % 4 = 0 THEN 'Bachiller'
        WHEN ID % 4 = 1 THEN 'Licenciatura'
        WHEN ID % 4 = 2 THEN 'Maestr�a'
        ELSE 'Doctorado'
    END,
    -- A�os experiencia (1-25)
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
(1, 'Renuncia por mejores oportunidades', 'Renuncia Voluntaria', 'Oportunidad Profesional', 1, 1, 'Empleado encontr� una mejor oferta laboral'),
(2, 'Renuncia por motivos personales', 'Renuncia Voluntaria', 'Personales', 1, 1, 'Motivos familiares o personales no especificados'),
(3, 'Renuncia por reubicaci�n geogr�fica', 'Renuncia Voluntaria', 'Cambio de ciudad/pa�s', 1, 1, 'Empleado se muda a otra ciudad'),
(4, 'Renuncia por estudios', 'Renuncia Voluntaria', 'Educaci�n', 1, 1, 'Deja el empleo para continuar estudios'),
(5, 'Renuncia por estr�s laboral', 'Renuncia Voluntaria', 'Salud Mental', 1, 1, 'Motivado por carga laboral o ambiente tenso'),

-- Terminaciones involuntarias
(6, 'Despido por bajo rendimiento', 'Despido Involuntario', 'Rendimiento', 0, 1, 'Empleado no cumpl�a con los objetivos establecidos'),
(7, 'Despido por faltas disciplinarias', 'Despido Involuntario', 'Disciplina', 0, 1, 'Incumplimiento de normas internas'),
(8, 'Despido por reducci�n de personal', 'Despido Involuntario', 'Reestructuraci�n', 0, 0, 'Decisi�n empresarial por recorte de presupuesto'),
(9, 'Despido por cierre de �rea o proyecto', 'Despido Involuntario', 'Cierre de operaciones', 0, 0, '�rea eliminada por decisi�n corporativa'),
(10, 'Despido por ausentismo reiterado', 'Despido Involuntario', 'Asistencia', 0, 1, 'Faltas injustificadas constantes'),

-- Otros motivos
(11, 'Jubilaci�n', 'Salida Natural', 'Edad de jubilaci�n', 1, 0, 'Empleado alcanz� edad de jubilaci�n'),
(12, 'Fallecimiento', 'Salida Involuntaria', 'Fallecimiento', 0, 0, 'Empleado falleci� durante relaci�n laboral'),
(13, 'Fin de contrato temporal', 'Fin de Contrato', 'Contrato vencido', 0, 0, 'No renovaci�n de contrato a plazo fijo'),
(14, 'Licencia prolongada sin retorno', 'Salida Administrativa', 'Licencia sin retorno', 0, 1, 'Empleado no se reincorpor� tras licencia'),
(15, 'Abandono de trabajo', 'Salida Involuntaria', 'Abandono', 0, 1, 'Empleado dej� de asistir sin aviso');

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
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 2024, GETDATE()),  -- Fecha de salida en los �ltimos 5 a�os
    (ABS(CHECKSUM(NEWID())) % 15) + 1,  -- ID_Motivo entre 1 y 10
    CASE (ID % 15)
        WHEN 0 THEN 'Renuncia por motivos personales.'
        WHEN 1 THEN 'Despido por bajo rendimiento.'
        WHEN 2 THEN 'Fin de contrato temporal.'
        WHEN 3 THEN 'Salida voluntaria por oportunidad laboral.'
        WHEN 4 THEN 'Reubicaci�n a otra ciudad.'
        WHEN 5 THEN 'Problemas de salud prolongados.'
        WHEN 6 THEN 'Jubilaci�n.'
        WHEN 7 THEN 'Decisi�n estrat�gica de la empresa.'
        WHEN 8 THEN 'Salida por estudios superiores.'
		WHEN 9 THEN 'Despido por bajo rendimiento.'
        WHEN 10 THEN 'Fin de contrato temporal.'
        WHEN 11 THEN 'Salida voluntaria por oportunidad laboral.'
        WHEN 12 THEN 'Reubicaci�n a otra ciudad.'
        WHEN 13 THEN 'Problemas de salud prolongados.'
        WHEN 14 THEN 'Jubilaci�n.'
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
    -- Nombre del servicio (combinaci�n de especialidad + tipo)
    CASE 
    WHEN ID % 20 BETWEEN 0 AND 4 THEN 'Consulta ' + 
        CASE ID % 5 
            WHEN 0 THEN 'General'
            WHEN 1 THEN 'de Medicina Interna'
            WHEN 2 THEN 'Pedi�trica'
            WHEN 3 THEN 'Ginecol�gica'
            ELSE 'Geri�trica' 
        END

    WHEN ID % 20 BETWEEN 5 AND 7 THEN 'Examen ' + 
        CASE ID % 3 
            WHEN 0 THEN 'de Sangre'
            WHEN 1 THEN 'de Orina'
            ELSE 'de Imagen (Rayos X)' 
        END

    WHEN ID % 20 BETWEEN 8 AND 10 THEN 'Terapia ' + 
        CASE ID % 3 
            WHEN 0 THEN 'F�sica'
            WHEN 1 THEN 'Psicol�gica'
            ELSE 'Respiratoria' 
        END

    WHEN ID % 20 BETWEEN 11 AND 13 THEN 'Cirug�a ' + 
        CASE ID % 3 
            WHEN 0 THEN 'Ambulatoria'
            WHEN 1 THEN 'Card�aca'
            ELSE 'Pl�stica' 
        END

    WHEN ID % 20 BETWEEN 14 AND 15 THEN 'Procedimiento ' + 
        CASE ID % 2 
            WHEN 0 THEN 'Endosc�pico'
            ELSE 'Quir�rgico Menor' 
        END

    WHEN ID % 20 = 16 THEN 'Hospitalizaci�n por Diagn�stico'

    WHEN ID % 20 = 17 THEN 'Consulta por Emergencia'

    WHEN ID % 20 = 18 THEN 'Servicio de Laboratorio Cl�nico'

    ELSE 'Atenci�n Domiciliaria'
	END,
    -- Descripci�n (combinaci�n aleatoria)
    CASE 
        WHEN ID % 10 = 0 THEN 'Procedimiento diagn�stico no invasivo'
        WHEN ID % 10 = 1 THEN 'Evaluaci�n especializada por profesional certificado'
        WHEN ID % 10 = 2 THEN 'Tratamiento terap�utico ambulatorio'
        WHEN ID % 10 = 3 THEN 'Intervenci�n quir�rgica con anestesia'
        WHEN ID % 10 = 4 THEN 'Estudio de laboratorio cl�nico'
        WHEN ID % 10 = 5 THEN 'Terapia de rehabilitaci�n f�sica'
        WHEN ID % 10 = 6 THEN 'Servicio de emergencia 24/7'
        WHEN ID % 10 = 7 THEN 'Consulta preventiva y de seguimiento'
        WHEN ID % 10 = 8 THEN 'Procedimiento con equipo especializado'
        ELSE 'Servicio m�dico integral multidisciplinario'
    END + ' - ' +
    CASE 
        WHEN ID % 8 = 0 THEN 'Requiere cita previa'
        WHEN ID % 8 = 1 THEN 'Disponible en horario extendido'
        WHEN ID % 8 = 2 THEN 'Con informe detallado'
        WHEN ID % 8 = 3 THEN 'Incluye materiales b�sicos'
        WHEN ID % 8 = 4 THEN 'Con seguimiento incluido'
        WHEN ID % 8 = 5 THEN 'Realizado por especialistas'
        WHEN ID % 8 = 6 THEN 'Con resultados inmediatos'
        ELSE 'Con opci�n de financiamiento'
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
    -- Fecha inicio (�ltimos 5 a�os)
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
    -- Costo real (variaci�n del costo base)
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
-- Tabla categor�as b�sicas de productos (8,000 registros)
------------------------------------------------------------------
INSERT INTO Categorias_Producto (ID_Categoria, Nombre, Descripcion) VALUES
(1, 'Medicamentos', 'Productos farmac�uticos para tratamiento de enfermedades'),
(2, 'Material de Curaci�n', 'Insumos para curaciones y procedimientos m�dicos'),
(3, 'Equipo M�dico', 'Instrumentos y dispositivos para diagn�stico y tratamiento'),
(4, 'Productos de Higiene', 'Art�culos para aseo y limpieza del paciente'),
(5, 'Insumos Hospitalarios', 'Material desechable para uso cl�nico'),
(6, 'Equipo de Protecci�n', 'Elementos de bioseguridad para personal m�dico'),
(7, 'Suplementos Nutricionales', 'Complementos alimenticios y vitam�nicos'),
(8, 'Productos para Laboratorio', 'Reactivos y materiales para an�lisis cl�nicos'),
(9, 'Ortopedia', 'Productos de apoyo y rehabilitaci�n f�sica'),
(10, 'Cuidado del Paciente', 'Art�culos para comodidad y cuidado del paciente');

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
    -- Categor�a (1-4)
    (ID % 4) + 1,
    -- Nombre producto
    CASE 
        WHEN ID % 10 = 0 THEN 'Omeprazol 20mg'
        WHEN ID % 10 = 1 THEN 'Paracetamol 500mg'
        WHEN ID % 10 = 2 THEN 'Ibuprofeno 400mg'
        WHEN ID % 10 = 3 THEN 'Amoxicilina 500mg'
        WHEN ID % 10 = 4 THEN 'Loratadina 10mg'
        WHEN ID % 10 = 5 THEN 'Jarabe para la tos'
        WHEN ID % 10 = 6 THEN 'Gasas est�riles'
        WHEN ID % 10 = 7 THEN 'Jeringas 5ml'
        WHEN ID % 10 = 8 THEN 'Guantes quir�rgicos'
        ELSE 'Term�metro digital'
    END,
    -- Descripci�n
    CASE 
        WHEN ID % 10 = 0 THEN 'Inhibidor de bomba de protones'
        WHEN ID % 10 = 1 THEN 'Analg�sico y antipir�tico'
        WHEN ID % 10 = 2 THEN 'Antiinflamatorio no esteroideo'
        WHEN ID % 10 = 3 THEN 'Antibi�tico de amplio espectro'
        WHEN ID % 10 = 4 THEN 'Antihistam�nico'
        WHEN ID % 10 = 5 THEN 'Alivia la tos seca'
        WHEN ID % 10 = 6 THEN 'Paquete de 10 unidades'
        WHEN ID % 10 = 7 THEN 'Caja de 50 unidades'
        WHEN ID % 10 = 8 THEN 'Talla M, caja de 100'
        ELSE 'Precisi�n �0.1�C'
    END,
    -- Precio venta (5-100)
    5 + (ID % 95),
    -- Costo compra (3-80)
    3 + (ID % 77),
    -- Stock (0-500)
    ID % 500,
    -- Stock m�nimo (10-100)
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
    -- Fecha (�ltimos 2 a�os)
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
    -- Fecha (�ltimos 2 a�os)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Descripci�n
    CASE 
        WHEN ID % 5 = 0 THEN 'Consulta m�dica'
        WHEN ID % 5 = 1 THEN 'Ex�menes de laboratorio'
        WHEN ID % 5 = 2 THEN 'Medicamentos'
        WHEN ID % 5 = 3 THEN 'Hospitalizaci�n'
        ELSE 'Procedimiento m�dico'
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
    -- Fecha (�ltimos 2 a�os)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Monto (50-2000)
    50 + (ID % 1950),
    -- M�todo de pago
    CASE 
        WHEN ID % 5 = 0 THEN 'Efectivo'
        WHEN ID % 5 = 1 THEN 'Tarjeta de cr�dito'
        WHEN ID % 5 = 2 THEN 'Tarjeta de d�bito'
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
-- Equipos de Diagn�stico (1-10)
(1, 'Electrocardi�grafo', 'Diagn�stico Card�aco', '2022-01-15', 'Activo', 'Consultorio 1', 7, 8500.00),
(2, 'Ec�grafo Port�til', 'Diagn�stico por Im�genes', '2021-11-20', 'Activo', 'Sala de Emergencias', 5, 12000.00),
(3, 'Monitor de Signos Vitales', 'Monitoreo', '2023-03-10', 'Activo', 'Quir�fano 1', 6, 6500.00),
(4, 'M�quina de Anestesia', 'Anestesiolog�a', '2020-09-05', 'En Mantenimiento', 'Quir�fano 2', 8, 18500.00),
(5, 'Resonador Magn�tico', 'Diagn�stico por Im�genes', '2022-06-18', 'Activo', '�rea de Im�genes', 10, 350000.00),
(6, 'Tom�grafo Computarizado', 'Diagn�stico por Im�genes', '2021-12-12', 'Activo', '�rea de Im�genes', 10, 280000.00),
(7, 'Mam�grafo Digital', 'Diagn�stico Mamario', '2023-01-30', 'Activo', '�rea de Im�genes', 7, 95000.00),
(8, 'Densit�metro �seo', 'Diagn�stico �seo', '2022-08-22', 'Activo', 'Laboratorio', 8, 45000.00),
(9, 'Espir�metro', 'Diagn�stico Respiratorio', '2023-02-15', 'Activo', 'Consultorio 2', 5, 3200.00),
(10, 'Otoscopio Digital', 'Diagn�stico Otorrino', '2023-04-05', 'Activo', 'Consultorio 3', 4, 2800.00),
-- Equipos de Laboratorio (11-20)
(11, 'Analizador Hematol�gico', 'Laboratorio', '2021-10-10', 'Activo', 'Laboratorio Central', 6, 42000.00),
(12, 'Centr�fuga', 'Laboratorio', '2022-05-12', 'Activo', 'Laboratorio Central', 5, 5800.00),
(13, 'Microscopio Electr�nico', 'Laboratorio', '2020-12-15', 'En Reparaci�n', 'Laboratorio Investigaci�n', 8, 75000.00),
(14, 'Autoclave', 'Esterilizaci�n', '2023-01-20', 'Activo', '�rea de Esterilizaci�n', 7, 12500.00),
(15, 'Ba�o Mar�a', 'Laboratorio', '2022-09-08', 'Activo', 'Laboratorio Central', 5, 3200.00),
(16, 'Contador Hematol�gico', 'Laboratorio', '2021-07-30', 'Activo', 'Laboratorio Central', 6, 38000.00),
(17, 'Incubadora', 'Laboratorio', '2023-03-15', 'Activo', 'Laboratorio Microbiolog�a', 6, 9500.00),
(18, 'Refrigerador de Sangre', 'Laboratorio', '2022-11-10', 'Activo', 'Banco de Sangre', 7, 8200.00),
(19, 'Analizador de Orina', 'Laboratorio', '2022-04-18', 'Activo', 'Laboratorio Central', 5, 18500.00),
(20, 'Agitador Vortex', 'Laboratorio', '2023-05-01', 'Activo', 'Laboratorio Central', 4, 1200.00),
-- Equipos de Tratamiento (21-30)
(21, 'Desfibrilador', 'Emergencias', '2022-02-28', 'Activo', 'Sala de Emergencias', 6, 9800.00),
(22, 'Bomba de Infusi�n', 'Tratamiento', '2023-01-10', 'Activo', 'Hospitalizaci�n', 5, 3200.00),
(23, 'Ventilador Mec�nico', 'Terapia Respiratoria', '2021-09-15', 'Activo', 'UCI', 7, 28500.00),
(24, 'L�ser M�dico', 'Dermatolog�a', '2022-07-20', 'Activo', 'Consultorio Dermatolog�a', 6, 42000.00),
(25, 'Equipo de Di�lisis', 'Nefrolog�a', '2020-11-05', 'En Mantenimiento', '�rea de Di�lisis', 8, 120000.00),
(26, 'Unidad de Electrocirug�a', 'Quir�rgico', '2023-02-12', 'Activo', 'Quir�fano 1', 7, 18500.00),
(27, 'C�mara Hiperb�rica', 'Medicina Hiperb�rica', '2021-12-10', 'Activo', '�rea de Terapias', 10, 95000.00),
(28, 'Equipo de Rayos L�ser', 'Oftalmolog�a', '2022-10-15', 'Activo', 'Consultorio Oftalmolog�a', 8, 65000.00),
(29, 'Unidad de Crioterapia', 'Dermatolog�a', '2023-03-25', 'Activo', 'Consultorio Dermatolog�a', 6, 28000.00),
(30, 'Equipo de Fisioterapia', 'Rehabilitaci�n', '2022-06-10', 'Activo', '�rea de Fisioterapia', 7, 32000.00),
-- Equipos de Soporte (31-40)
(31, 'Carro de Emergencias', 'Emergencias', '2023-01-15', 'Activo', 'Sala de Emergencias', 5, 4500.00),
(32, 'Cama Hospitalaria', 'Hospitalizaci�n', '2022-08-20', 'Activo', 'Piso 2 - Habitaci�n 201', 8, 2800.00),
(33, 'Mesa Quir�rgica', 'Quir�rgico', '2021-05-12', 'Activo', 'Quir�fano 1', 10, 18500.00),
(34, 'L�mpara Quir�rgica', 'Quir�rgico', '2022-11-30', 'Activo', 'Quir�fano 2', 7, 9500.00),
(35, 'Estaci�n de Enfermer�a', 'Monitoreo', '2023-02-18', 'Activo', 'Hospitalizaci�n', 6, 6500.00),
(36, 'Silla de Ruedas', 'Movilidad', '2022-09-10', 'Activo', 'Entrada Principal', 4, 850.00),
(37, 'Camilla de Transporte', 'Movilidad', '2023-04-05', 'Activo', 'Sala de Emergencias', 5, 1200.00),
(38, 'Estetoscopio Electr�nico', 'Diagn�stico', '2023-03-15', 'Activo', 'Consultorio 1', 4, 650.00),
(39, 'Nebulizador', 'Terapia Respiratoria', '2022-12-10', 'Activo', 'Consultorio Neumolog�a', 5, 980.00),
(40, 'Ox�metro de Pulso', 'Monitoreo', '2023-05-20', 'Activo', 'Hospitalizaci�n', 4, 450.00);

------------------------------------------------------------------
-- Tabla Tipos de Gastos (8,000 registros)
------------------------------------------------------------------
INSERT INTO Tipo_Gasto (ID_Tipo_Gasto, Nombre, Descripcion, Categoria) VALUES
-- Costos Directos (1-10)
(1, 'Materiales M�dicos', 'Compra de insumos m�dicos descartables', 'Directo'),
(2, 'Medicamentos', 'Adquisici�n de f�rmacos para farmacia', 'Directo'),
(3, 'Salario M�dico', 'Honorarios de profesionales m�dicos', 'Directo'),
(4, 'Equipos M�dicos', 'Compra de equipos para diagn�stico/t tratamiento', 'Directo'),
(5, 'Suministros Cl�nicos', 'Material de curaci�n y procedimientos', 'Directo'),
(6, 'Honorarios Profesionales', 'Pago a especialistas externos', 'Directo'),
(7, 'Reactivos Laboratorio', 'Insumos para an�lisis cl�nicos', 'Directo'),
(8, 'Material Quir�rgico', 'Insumos para salas de operaciones', 'Directo'),
(9, 'Pr�tesis e Implantes', 'Materiales para cirug�as', 'Directo'),
(10, 'Ayudas Diagn�sticas', 'Estudios externos para pacientes', 'Directo'),
-- Costos Indirectos (11-20)
(11, 'Administraci�n', 'Gastos de personal administrativo', 'Indirecto'),
(12, 'Limpieza', 'Servicios de aseo y mantenimiento', 'Indirecto'),
(13, 'Servicios P�blicos', 'Agua, luz, gas, telecomunicaciones', 'Indirecto'),
(14, 'Seguros', 'P�lizas de seguro de la cl�nica', 'Indirecto'),
(15, 'Capacitaci�n', 'Entrenamiento para el personal', 'Indirecto'),
(16, 'Sistemas', 'Mantenimiento de software administrativo', 'Indirecto'),
(17, 'Gastos Legales', 'Honorarios de abogados y tr�mites', 'Indirecto'),
(18, 'Papeler�a', 'Material de oficina y formularios', 'Indirecto'),
(19, 'Mantenimiento', 'Reparaciones generales', 'Indirecto'),
(20, 'Utilitarios', 'Gastos varios de operaci�n', 'Indirecto'),
-- Costos de Tecnolog�a (21-25)
(21, 'Software M�dico', 'Licencias de sistemas cl�nicos', 'Tecnolog�a'),
(22, 'Hardware', 'Equipos de computaci�n y redes', 'Tecnolog�a'),
(23, 'Mantenimiento TI', 'Soporte t�cnico especializado', 'Tecnolog�a'),
(24, 'Servicios en Nube', 'Almacenamiento y backups', 'Tecnolog�a'),
(25, 'Ciberseguridad', 'Protecci�n de datos y sistemas', 'Tecnolog�a'),
-- Costos de Marketing (26-30)
(26, 'Publicidad Digital', 'Campa�as en redes y buscadores', 'Marketing'),
(27, 'Material Promocional', 'Folletos y banners', 'Marketing'),
(28, 'Eventos M�dicos', 'Participaci�n en congresos', 'Marketing'),
(29, 'Dise�o Gr�fico', 'Creaci�n de material visual', 'Marketing'),
(30, 'Estudios de Mercado', 'Investigaci�n de pacientes', 'Marketing'),
-- Costos de Infraestructura (31-35)
(31, 'Remodelaciones', 'Adecuaci�n de espacios cl�nicos', 'Infraestructura'),
(32, 'Mobiliario', 'Compra de camas y equipamiento', 'Infraestructura'),
(33, 'Equipos Cl�nicos', 'Maquinaria pesada para hospitalizaci�n', 'Infraestructura'),
(34, 'Sistemas El�ctricos', 'Mejoras en instalaciones', 'Infraestructura'),
(35, 'Adecuaciones Especiales', 'Salas limpias y quir�fanos', 'Infraestructura'),
-- Otros gastos (36-40)
(36, 'Amortizaciones', 'Depreciaci�n de activos fijos', 'Financiero'),
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
    -- Fecha (�ltimos 2 a�os)
    DATEADD(DAY, - (ID % 730), GETDATE()),
    -- Descripci�n
    CASE 
        WHEN ID % 7 = 0 THEN 'Compra de medicamentos'
        WHEN ID % 7 = 1 THEN 'Mantenimiento de equipos'
        WHEN ID % 7 = 2 THEN 'Pago de servicios b�sicos'
        WHEN ID % 7 = 3 THEN 'Capacitaci�n del personal'
        WHEN ID % 7 = 4 THEN 'Publicidad y marketing'
        WHEN ID % 7 = 5 THEN 'Reparaciones de infraestructura'
        ELSE 'Adquisici�n de nuevos equipos'
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
    -- Fecha (�ltimos 5 a�os)
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

    -- Infraestructura (versi�n corregida)
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
        WHEN ID % 5 = 0 THEN 'Excelente atenci�n'
        WHEN ID % 5 = 1 THEN 'Podr�a mejorar'
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
    -- Fecha (�ltimos 5 a�os)
    DATEADD(DAY, - (ID % 2024), GETDATE()),
    -- Tipo Reclamo
    CASE 
        WHEN ID % 5 = 0 THEN 'Atenci�n m�dica'
        WHEN ID % 5 = 1 THEN 'Tiempo de espera'
        WHEN ID % 5 = 2 THEN 'Facturaci�n'
        WHEN ID % 5 = 3 THEN 'Limpieza'
        ELSE 'Trato del personal'
    END,
    -- Descripci�n
    CASE 
        WHEN ID % 5 = 0 THEN 'El m�dico no fue claro en el diagn�stico'
        WHEN ID % 5 = 1 THEN 'Esper� m�s de 2 horas para ser atendido'
        WHEN ID % 5 = 2 THEN 'Error en la factura de mi consulta'
        WHEN ID % 5 = 3 THEN 'El ba�o estaba sucio durante mi visita'
        ELSE 'Recepcionista fue grosero conmigo'
    END,
    -- ID Empleado Asignado (1-8000, 80% no nulos)
    CASE WHEN ID % 5 = 0 THEN NULL ELSE (ID % 8000) + 1 END,
    -- Respuesta
    CASE 
        WHEN ID % 5 = 0 THEN 'Hablaremos con el profesional para mejorar la comunicaci�n'
        WHEN ID % 5 = 1 THEN 'Lamentamos la demora. Estamos contratando m�s personal'
        WHEN ID % 5 = 2 THEN 'Hemos corregido el error y enviado nueva factura'
        WHEN ID % 5 = 3 THEN 'Hemos reforzado el protocolo de limpieza'
        ELSE 'El empleado recibi� capacitaci�n adicional'
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
    -- Fecha (�ltimos 2 a�os)
    DATEADD(DAY, - (ID % 1200), GETDATE()),
    -- Plataforma
    CASE 
        WHEN ID % 3 = 0 THEN 'App M�vil'
        WHEN ID % 3 = 1 THEN 'Sitio Web'
        ELSE 'Portal Pacientes'
    END,
    -- Puntaje (1-5)
    (ID % 5) + 1,
    -- Comentario
    CASE 
        WHEN ID % 5 = 0 THEN 'Muy f�cil de usar, excelente experiencia'
        WHEN ID % 5 = 1 THEN 'La aplicaci�n se cierra frecuentemente'
        WHEN ID % 5 = 2 THEN 'Podr�an mejorar el dise�o de la interfaz'
        WHEN ID % 5 = 3 THEN 'No puedo acceder a mis resultados m�dicos'
        ELSE 'Funciona perfectamente, muy satisfecho'
    END,
    -- Respuesta
    CASE 
        WHEN ID % 5 = 0 THEN '�Gracias por tu feedback positivo!'
        WHEN ID % 5 = 1 THEN 'Estamos trabajando en la estabilidad de la app'
        WHEN ID % 5 = 2 THEN 'Tenemos planeado un redise�o para el pr�ximo trimestre'
        WHEN ID % 5 = 3 THEN 'Por favor cont�ctenos para ayudarte con este problema'
        ELSE 'Nos alegra que tengas buena experiencia con nuestra plataforma'
    END,
	-- Fecha Respuesta (100% con fecha)
	DATEADD(DAY, 1 + (ID % 7), DATEADD(DAY, - (ID % 600), GETDATE()))
    /*-- Fecha Respuesta (60% tienen fecha)
    CASE WHEN ID % 5 < 3 THEN NULL ELSE DATEADD(DAY, 1 + (ID % 7), DATEADD(DAY, - (ID % 730), GETDATE())) END*/
FROM Numbers;