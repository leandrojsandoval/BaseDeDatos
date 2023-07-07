/*Ejercicio 6: Dada la siguiente base de datos

	Vuelo (NroVuelo, Desde, Hasta, Fecha)
	AvionUtilizado (NroVuelo, TipoAvion, NroAvion)
	InfoPasajeros(NroVuelo, Documento, Nombre, Origen, Destino)

Nota: Los vuelos no pueden tener m�s de 2 escalas y no hay cambio de tipo de avi�n para un mismo vuelo.*/

USE Ejercicio_6;
GO

-- 1. Hallar los n�meros de vuelo desde el origen A hasta el destino F.

SELECT ip.NroVuelo
FROM InfoPasajeros AS ip
WHERE ip.Origen = 'A' AND ip.Destino = 'F'

-- 2. Hallar los tipos de avi�n que no son utilizados en ning�n vuelo que pase por B.

SELECT au.TipoAvion
FROM AvionUtilizado AS au
EXCEPT
SELECT au.TipoAvion
FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON au.NroVuelo = ip.NroVuelo
WHERE ip.Origen = 'B' OR ip.Destino = 'B'

-- 3. Hallar los pasajeros y n�meros de vuelo para aquellos pasajeros que viajan desde A a D pasando por B.

SELECT ip1.Documento, ip1.NroVuelo
FROM InfoPasajeros AS ip1 JOIN InfoPasajeros AS ip2 ON ip1.Documento = ip2.Documento AND ip1.Destino = ip2.Origen
WHERE ip1.Origen = 'A' AND ip1.Destino = 'B' AND ip2.Destino = 'D'

-- 4. Hallar los tipos de avi�n que pasan por C.

SELECT au.TipoAvion
FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON ip.NroVuelo = au.NroVuelo
WHERE ip.Destino = 'C' OR ip.Origen = 'C'

-- 5. Hallar por cada Avi�n la cantidad de vuelos distintos en que se encuentra registrado.

SELECT au.NroAvion, COUNT(DISTINCT au.NroVuelo) [Cantidad de vuelos distintos]
FROM AvionUtilizado AS au
GROUP BY au.NroAvion

-- 6. Listar los distintos tipo y nro. de avi�n que tienen a H como destino.

SELECT au.TipoAvion, au.NroAvion
FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON ip.NroVuelo = au.NroVuelo
WHERE ip.Destino = 'H'

-- 7. Hallar los pasajeros que han volado m�s frecuentemente en el �ltimo a�o.

CREATE OR ALTER VIEW vCantidadDeVuelosEsteA�oPorPasajeros AS
(
	SELECT ip.Documento, COUNT(*) [Cantidad de vuelos en este a�o]
	FROM Vuelo AS v JOIN InfoPasajeros AS ip ON v.NroVuelo = ip.NroVuelo
	WHERE YEAR(v.Fecha) = YEAR(GETDATE())
	GROUP BY ip.Documento
)

SELECT v.Documento
FROM vCantidadDeVuelosEsteA�oPorPasajeros AS v
WHERE v.[Cantidad de vuelos en este a�o] = (SELECT MAX([Cantidad de vuelos en este a�o]) 
											FROM vCantidadDeVuelosEsteA�oPorPasajeros)

-- 8. Hallar los pasajeros que han volado la mayor cantidad de veces posible en un B-777.

CREATE OR ALTER VIEW vCantidadDeVuelosPorPasajeroEnB777 AS
(
	SELECT ip.Documento, COUNT(*) [Cantidad de vuelos con B-777]
	FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON ip.NroVuelo = au.NroVuelo
	WHERE au.TipoAvion = 'B-777'
	GROUP BY ip.Documento
)

SELECT v.Documento
FROM vCantidadDeVuelosPorPasajeroEnB777 AS v
WHERE v.[Cantidad de vuelos con B-777] = (SELECT MAX([Cantidad de vuelos con B-777])
										  FROM vCantidadDeVuelosPorPasajeroEnB777)

-- 9. Hallar los aviones que han transportado m�s veces al pasajero m�s antiguo.

CREATE OR ALTER VIEW vAvionesQueTransportaronAlPasajeroMasAntiguo AS
(
	SELECT au.NroAvion, COUNT(*) [Cantidad de veces transportado]
	FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON ip.NroVuelo = au.NroVuelo
	WHERE ip.Documento = (SELECT MIN(Documento) FROM InfoPasajeros)
	GROUP BY au.NroAvion
)

SELECT v.NroAvion
FROM vAvionesQueTransportaronAlPasajeroMasAntiguo AS v
WHERE v.[Cantidad de veces transportado] = (SELECT MAX([Cantidad de veces transportado])
											FROM vAvionesQueTransportaronAlPasajeroMasAntiguo)

-- 10. Listar la cantidad promedio de pasajeros transportados por los aviones de la compa��a, por tipo de avi�n.

SELECT au.TipoAvion, COUNT(DISTINCT ip.Documento) AS [Cantidad de pasajeros transportados]
FROM InfoPasajeros AS ip JOIN AvionUtilizado AS au ON ip.NroVuelo = au.NroVuelo
GROUP BY au.TipoAvion

-- 11. Hallar los pasajeros que han realizado una cantidad de vuelos dentro del 10% en m�s o en menos del promedio
-- de vuelos de todos los pasajeros de la compa��a.

SELECT ip.Documento, COUNT(*) [Cantidad de vuelos]
FROM InfoPasajeros AS ip 
GROUP BY ip.Documento
HAVING COUNT(*) >= (SELECT COUNT(*) * 0.1 [10% de los vuelos totales]
					FROM Vuelo)
