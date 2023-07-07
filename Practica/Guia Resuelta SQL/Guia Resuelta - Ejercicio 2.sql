/*Ejercicio 2:

	Galer�aDeArte (Id, Nombre, Disponible, Calle, Nro, Localidad)
	Obra (Id, Nombre, Material, IdTipo, IdAutor)
	TipoDeObra (Id, Descripcion)
	Tem�tica (Id, Descripcion)
	Exposici�n (IdGaleria, IdObra, IdTematica, Fecha, Sala)
	Autor (Id, NyA, FechaNacimiento)*/

CREATE DATABASE GuiaResueltaEjercicio2
GO
USE GuiaResueltaEjercicio2
GO
	
CREATE TABLE GaleriaDeArte
(
	Id INT PRIMARY KEY, 
	Nombre VARCHAR (50), 
	Disponible VARCHAR (50), 
	Calle VARCHAR (50), 
	Numero VARCHAR (50), 
	Localidad VARCHAR (50)
);

CREATE TABLE Autor
(
	Id INT PRIMARY KEY, 
	NyA VARCHAR (50), 
	FechaNacimiento	DATE 
);

CREATE TABLE TipoDeObra
(
	Id INT PRIMARY KEY, 
	Descripcion VARCHAR (50)
);

CREATE TABLE Tematica
(
	Id INT PRIMARY KEY, 
	Descripci�n	VARCHAR (50)
);

CREATE TABLE Obra
(
	Id INT PRIMARY KEY, 
	Nombre VARCHAR (50), 
	Material VARCHAR (50),
	IdTipo INT, 
	IdAutor	INT,
	FOREIGN KEY	(IdTipo) REFERENCES TipoDeObra(Id),
	FOREIGN KEY	(IdAutor) REFERENCES Autor(Id)
);

CREATE TABLE Exposicion
(
	IdGaleria INT, 
	IdObra INT, 
	IdTematica INT, 
	Fecha DATE, 
	Sala INT,
	PRIMARY KEY	(IdGaleria, IdObra, IdTematica, Fecha),
	FOREIGN KEY	(IdGaleria) REFERENCES GaleriaDeArte (Id),
	FOREIGN KEY	(IdObra) REFERENCES TipoDeObra(Id),
	FOREIGN KEY	(IdTematica) REFERENCES Tematica(Id)
);

INSERT INTO GaleriaDeArte (Id, Nombre, Disponible, Calle, Numero, Localidad) VALUES
(1, 'Galeria Barcelona', 'S', 'C/ de Bailen', '19','El Poblenou'),
(2, 'Galeria Buenos Aires', 'N', 'Av. del Libertador', '1473','CABA'),
(3, 'Galeria Florencia', 'N', 'Av. Corrientes', '565','CABA'),
(4, 'Galeria Recoleta', 'S', 'Junin', '1930','CABA'),
(5, 'Galeria Orfeo', 'S', 'Juncal', '848','CABA');

INSERT INTO Autor (Id, NyA, FechaNacimiento) VALUES
(1, 'Dali', '1904-05-11'),
(2, 'Picasso', '1881-10-25'),
(3, 'Joan Miro', '1893-04-20'),
(4, 'Max Ernst', '1891-04-02'),
(5, 'Man Ray', '1890-08-27');

INSERT INTO TipoDeObra (Id, Descripcion) VALUES
(1,'Dada�smo'),
(2,'Surrealismo'),
(3,'Pop art'),
(4,'Art Deco'),
(5,'Minimalismo');

INSERT INTO Tematica (Id, Descripci�n) VALUES 
(1,'Oregon'),
(2,'Paisaje'),
(3,'Emociones'),
(4,'Figura humana'),
(5,'Retrato');

INSERT INTO Obra (Id, Nombre, Material, IdTipo, IdAutor) VALUES 
(1,'Guernica','Oleo sobre lienzo',2,2),
(2,'La persistencia de la memoria','Oleo sobre lienzo',5,1),
(3,'La mujer que llora','Pintura al aceite',3,2),
(4,'Gift','Painted flatiron',1,5),
(5,'La masia','Oleo sobre lienzo',4,3);

INSERT INTO Exposicion (IdGaleria, IdObra, IdTematica, Fecha, Sala) VALUES 
(1,1,2,'15-04-2021',4),
(1,2,2,'22-07-2021',1),
(2,3,3,'30-10-2021',1),
(2,1,2,'30-10-2021',2),
(2,2,4,'30-10-2021',3),
(2,3,5,'30-10-2021',4),
(2,5,1,GETDATE(),9),
(2,4,1,GETDATE(),1),
(2,2,1,GETDATE(),1),
(5,4,1,'01-02-2021',2);

/*a - Obtener el nombre de la galer�a de arte, la descripci�n de la tem�tica presentada y la fecha de 
realizaci�n, cuando la exposici�n tuvo la mayor cantidad de obras en expuestas. S�lo se mostrar�n los resultados
siempre y cuando la galer�a de arte haya presentado todas las tem�ticas disponibles o haya expuesto distintas 
obras a tal punto de haber presentado todos los tipos de obra disponibles.*/

CREATE OR ALTER VIEW v_Exposicion_Cantidad_Obras AS
(
	SELECT DISTINCT e.IdGaleria, e.IdTematica, e.Fecha, COUNT(e.IdObra) 'Cantidad Obras'
	FROM Exposicion AS e
	GROUP BY e.IdGaleria, e.IdTematica, e.Fecha
)

-- Exposicion que tuvo la mayor cantidad de obras expuestas (Por galeria, tematica y fecha)
CREATE OR ALTER VIEW v_Exposicion_ObrasMax AS
(
	SELECT eco.IdGaleria, eco.IdTematica, eco.Fecha
	FROM v_Exposicion_Cantidad_Obras AS eco
	WHERE eco.[Cantidad Obras] = (SELECT MAX(eco.[Cantidad Obras]) 
								  FROM v_Exposicion_Cantidad_Obras AS eco)
)

-- Galerias de arte que presentaron todas las tematicas disponibles.
CREATE OR ALTER VIEW v_Galeria_TodasTematicas AS
(
	SELECT e.IdGaleria, COUNT(DISTINCT e.IdTematica) AS 'Tematicas Presentadas'
	FROM Exposicion AS e
	GROUP BY e.IdGaleria
	HAVING COUNT(DISTINCT e.IdTematica) = (SELECT COUNT(*) 'Cantidad de tematicas'
										   FROM Tematica)
)

-- Galerias de arte que expusieron obras, que tengan todos los tipos de obra disponibles.
CREATE OR ALTER VIEW  v_Galeria_TodosTiposObra AS
(
	SELECT e.IdGaleria, COUNT(DISTINCT o.IdTipo) AS 'Cantidad Tipos Obra'
	FROM Exposicion AS e INNER JOIN Obra AS o ON e.IdObra = o.Id
	GROUP BY e.IdGaleria
	HAVING COUNT(DISTINCT o.IdTipo) = (SELECT COUNT(*) 'Cantidad Tipos de Obra'
									   FROM TipoDeObra)
)

SELECT g.Nombre, t.Descripci�n, eom.Fecha
FROM GaleriaDeArte AS g  INNER JOIN v_Exposicion_ObrasMax AS eom ON eom.IdGaleria = g.Id
						 INNER JOIN Tematica AS t ON eom.IdTematica = t.Id
WHERE eom.IdGaleria IN (SELECT gtt.IdGaleria 
						FROM v_Galeria_TodasTematicas AS gtt) 
   OR eom.IdGaleria IN (SELECT gtto.IdGaleria 
						FROM v_Galeria_TodosTiposObra AS gtto)

/*b - Se requiere crear un procedimiento almacenados o funci�n para generar una nueva exposici�n, por lo tanto 
se desea recibir por par�metro, el id de la galer�a de arte, id de la tem�tica, id de la obra a participar y 
la fecha. Si la exposici�n no existe se deber� asignar el n�mero de sala �1�, pero si la exposici�n ya existiera 
deber� utilizarse el n�mero de sala previamente cargado para la misma.
Aclaraci�n: Deber� validar que los id recibidos por par�metros existan en las tablas correspondientes.*/

CREATE OR ALTER PROCEDURE p_Nueva_Exposicion (@IdGaleria INT, @IdObra INT, @IdTematica INT, @Fecha DATE)
AS
BEGIN
	DECLARE @Sala AS INT;
	DECLARE @FlagGaleria AS INT = (SELECT 1 FROM GaleriaDeArte WHERE Id = @IdGaleria)
	DECLARE @FlagTematica AS INT = (SELECT 1 FROM Tematica WHERE Id = @IdTematica)
	DECLARE @FlagObra AS INT = (SELECT 1 FROM Obra WHERE Id = @IdObra)
	IF (@FlagGaleria = 1 AND @FlagTematica = 1 AND @FlagObra = 1) -- Ids validos
	BEGIN
		DECLARE @FlagExposicion AS INT = (SELECT 1 FROM Exposicion WHERE IdObra = @IdObra AND IdTematica = @IdTematica AND IdGaleria = @IdGaleria)
		IF (@FlagExposicion = 1)
			SET @Sala = (SELECT TOP 1 e.Sala FROM Exposicion AS e WHERE IdObra = @IdObra AND IdTematica = @IdTematica AND IdGaleria = @IdGaleria)
		ELSE
			SET @Sala = 1
		INSERT INTO Exposicion (IdGaleria, IdTematica, IdObra, Fecha, Sala) VALUES (@IdGaleria, @IdTematica, @IdObra, @Fecha, @Sala)
	END
	ELSE
		RAISERROR ('Los parametros ingresados no son validos',11,1)
END

EXECUTE p_Nueva_Exposicion 1,1,2,'25-04-2021'

