/*Ejercicio 13: Dado el siguiente esquema de relaci�n
	Medici�n(fecha,hora,m�trica,temperatura,presi�n,humedad,nivel)
	Nivel (c�digo, descripci�n)*/

CREATE DATABASE Ejercicio13
GO
USE Ejercicio13
GO

/*1. p_CrearEntidades(): Realizar un procedimiento que permita crear las tablas de nuestro modelo relacional.*/

CREATE OR ALTER PROCEDURE p_CrearEntidades AS
BEGIN
	CREATE TABLE Nivel
	(
		Codigo INT PRIMARY KEY,
		Descripcion VARCHAR(15)
	)

	CREATE TABLE Medicion
	(
		Fecha DATE,
		Hora TIME,
		Metrica CHAR(2),
		Temperatura INT,
		Presion INT,
		Humedad INT,
		Nivel INT,
		CONSTRAINT FK_Medicion PRIMARY KEY (Fecha,Hora,Metrica)
	)
	ALTER TABLE Medicion ADD CONSTRAINT FK_Medicion_Nivel FOREIGN KEY (Nivel) REFERENCES Nivel (Codigo) ON DELETE CASCADE ON UPDATE CASCADE
END

EXECUTE p_CrearEntidades

INSERT INTO Nivel (Codigo, Descripcion) VALUES
(1,'Maritimo'),
(2,'Terrestre'),
(3,'Aereo'),
(4,'Espacial'),
(5,'Volcanico');

INSERT INTO Medicion (Fecha, Hora, Metrica, Temperatura, Presion, Humedad, Nivel) VALUES
('15-04-2021','12:04:00','M1',30,4,12,5),
('22-12-2021','21:59:04','M2',1,42,23,1),
(GETDATE(),'04:20:00','M3',66,7,55,4),
('27-07-2021','07:30:15','M4',33,1,15,2),
('22-12-2021','06:30:00','M3',25,3,25,1),
('20-12-2021','09:50:00','M3',-23,4,50,2),
('21-12-2021','15:55:30','M3',5,1,40,3),
('19-12-2021','16:00:00','M3',0,17,35,5),
('18-12-2021','20:30:59','M3',22,5,10,5);

/*2. f_ultimamedicion(M�trica): Realizar una funci�n que devuelva la fecha y hora de la �ltima medici�n realizada 
en una m�trica espec�fica, la cual ser� enviada por par�metro. 
La sintaxis de la funci�n deber� respetar lo siguiente:
	Fecha/hora = f_ultimamedicion(vMetrica char(5))
Ejemplificar el uso de la funci�n.*/

CREATE OR ALTER FUNCTION f_ultimamedicion (@vMetrica char(5)) RETURNS TABLE AS
	RETURN (SELECT MAX(m.Fecha) 'Ultima Fecha', MAX(m.Hora) 'Ultima hora' 
			FROM Medicion AS m WHERE m.Metrica = @vMetrica)

SELECT *
FROM f_ultimamedicion('M1')

/*3. v_Listado: Realizar una vista que permita listar las m�tricas en las cuales se hayan realizado, en la �ltima 
semana, mediciones para todos los niveles existentes. El resultado del listado deber� mostrar, el nombre de la
m�trica que respete la condici�n enunciada, el m�ximo nivel de temperatura de la �ltima semana y la cantidad de 
mediciones realizadas tambi�n en la �ltima semana.*/

CREATE VIEW v_Listado AS
(
	SELECT m.Metrica, MAX(m.Temperatura) 'Tempeatura maxima', COUNT(*) 'Cantidad de mediciones'
	FROM Medicion AS m
	WHERE m.Fecha >= GETDATE() - 7
	GROUP BY m.Metrica
	HAVING COUNT(DISTINCT m.Nivel) = (SELECT COUNT(*) 'Cantidad total de niveles' FROM Nivel AS n)
)

SELECT *
FROM v_Listado 

/*4. p_ListaAcumulados(finicio,ffin): Realizar un procedimiento que permita generar una tabla de acumulados 
diarios de temperatura por cada m�trica y por cada d�a. El procedimiento deber� admitir como par�metro el rango 
de fechas que mostrar� el reporte. Adem�s, estas fechas deben ser validadas. El informe se deber� visualizar de 
la siguiente forma:
								Fecha		Metrica		Ac.DiarioTemp	Ac.Temp
								01/03/2009	M1			25				25
								02/03/2009	M1			20				45
								03/03/2009	M1			15				60
								01/03/2009	M2			15				15
								02/03/2009	M2			10				25
*/

CREATE OR ALTER PROCEDURE p_ListaAcumulados (@FInicio DATE, @FFin DATE) AS
BEGIN
	SELECT m.Fecha, m.Metrica, COUNT(m.Temperatura) 'Ac. Diario Temp', SUM(m.Temperatura) 'Ac. Temp'
	FROM Medicion AS m
	WHERE m.Fecha >= @FInicio AND m.Fecha <= @FFin
	GROUP BY m.Fecha, m.Metrica
END

EXECUTE p_ListaAcumulados '18-12-2020', '18-12-2021'

/*5. p_InsertMedicion (Fecha, Hora, Metrica, Temp, Presion, Hum, Niv): Realizar un procedimiento que permita agregar 
una nueva medici�n en su respectiva entidad. Los par�metros deber�n ser validados seg�n:
	a. Para una nueva fecha hora, no puede haber m�s de una medida por m�trica
	b. El valor de humedad s�lo podr� efectuarse entre 0 y 100.
	c. El campo nivel deber� ser v�lido, seg�n su correspondiente entidad.*/

CREATE OR ALTER PROCEDURE p_InsertMedicion (@Fecha DATE, @Hora TIME, @Metrica CHAR(2), @Temp INT, @Presion INT, @Hum INT, @Niv INT) AS
BEGIN
	DECLARE @FlagNivel INT = (SELECT 1 FROM Nivel AS n WHERE @Niv = n.Codigo)
	DECLARE @FlagFecha INT = (SELECT 1 FROM Medicion AS m WHERE @Fecha = m.Fecha AND @Metrica <> m.Metrica)
	IF (@FlagNivel = 1 AND @FlagFecha = 1 AND (@Hum >= 0 AND @Hum <= 100))
		INSERT INTO Medicion (Fecha, Hora, Metrica, Temperatura, Presion, Humedad, Nivel) VALUES (@Fecha, @Hora, @Metrica, @Temp, @Presion, @Hum, @Niv)
	ELSE
		RAISERROR ('No se pudo insertar la medicion ingresada',11,1);
END

/*6. p_depuraMedicion(d�as): Realizar un procedimiento que depure la tabla de mediciones, dejando s�lo las �ltimas
mediciones. El resto de las mediciones, no deben ser borradas sino trasladadas a otra entidad que llamaremos 
Medicion_Hist. El proceso deber� tener como par�metro la cantidad de d�as de retenci�n de las mediciones.*/

CREATE TABLE MedicionHistorica
(
	Fecha DATE,
	Hora TIME,
	Metrica CHAR(2),
	Temperatura INT,
	Presion INT,
	Humedad INT,
	Nivel INT,
	CONSTRAINT FK_MedicionHistorica PRIMARY KEY (Fecha,Hora,Metrica)
)

CREATE OR ALTER PROCEDURE p_DepuraMedicion (@Dias INT) AS
BEGIN
	INSERT INTO MedicionHistorica SELECT * FROM Medicion AS m WHERE m.Fecha <= GETDATE() - @Dias
	DELETE FROM Medicion WHERE Fecha <= GETDATE() - @Dias
END

EXECUTE p_DepuraMedicion 7

/*7. tg_descNivel: Realizar un trigger que coloque la descripci�n en may�scula cada vez que se inserte un nuevo 
nivel.*/

CREATE OR ALTER TRIGGER tg_DescNivel ON Nivel INSTEAD OF INSERT AS
BEGIN
	DECLARE @Descripcion VARCHAR(15) = (SELECT UPPER(i.Descripcion) FROM Inserted AS i)
	DECLARE @Codigo INT = (SELECT i.Codigo FROM Inserted AS i)
	INSERT INTO Nivel (Codigo, Descripcion) VALUES (@Codigo, @Descripcion)
END

INSERT INTO Nivel (Codigo, Descripcion) VALUES (6,'Eolico')