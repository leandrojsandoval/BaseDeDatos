/*
USE master
DROP DATABASE Ejercicio_5
*/
USE master

CREATE DATABASE Ejercicio_5
GO

USE Ejercicio_5

/*
Pel�cula (CodPel, T�tulo, Duraci�n, A�o, CodRubro)
Rubro    (CodRubro, NombRubro)

Ejemplar (CodEj, CodPel, Estado, Ubicaci�n) 
          Estado: Libre, Ocupado
Cliente  (CodCli, Nombre, Apellido, Direccion, Tel, Email)
Pr�stamo (CodPrest, CodEj, CodPel, CodCli, FechaPrest, FechaDev)

*/

CREATE TABLE Rubro
(
	CodRubro INT IDENTITY(1,1) PRIMARY KEY,
	NombRubro VARCHAR(20) NOT NULL 
)

CREATE TABLE Pelicula
(
	CodPel INT IDENTITY(1,1) PRIMARY KEY,
	Titulo VARCHAR(50) NOT NULL,
	Duracion decimal(6,2),
	Anio INT,
	CodRubro INT
	CONSTRAINT FK_CodRubro FOREIGN KEY (CodRubro) REFERENCES Rubro(CodRubro)
)

CREATE TABLE Ejemplar
(
	CodEj INT NOT NULL,
	CodPel INT NOT NULL,
	Estado BIT NOT NULL,
	Ubicaci�n VARCHAR(10)
)

ALTER TABLE Ejemplar ADD CONSTRAINT PK_CodEjPel PRIMARY KEY (CodEj, CodPel);
ALTER TABLE Ejemplar ADD CONSTRAINT FK_Pelicula FOREIGN KEY (CodPel) REFERENCES Pelicula(CodPel);

CREATE TABLE Cliente
(
	CodCli INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(20) NOT NULL,
	Apellido VARCHAR(20) NOT NULL,
	Direccion VARCHAR(20)  NULL,
	Tel VARCHAR(20)  NULL,
	Email VARCHAR(20)  NULL
)

CREATE TABLE Prestamo
(
	CodPrest INT IDENTITY(1,1) PRIMARY KEY,
	CodEj INT NOT NULL,
	CodPel INT NOT NULL,
	CodCli INT  NULL,
	FechaPrest DATETIME NOT NULL,
	FechaDev DATETIME  NULL 
)
