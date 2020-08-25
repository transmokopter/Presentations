--DBCC FREEPROCCACHE will throw out cached plans from cache. Don't use in production, OK!
DBCC FREEPROCCACHE;
--This is what Ola Hallengrens solution will do on a nightly basis
UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;
SET STATISTICS IO ON;

--Remember to enable actual execution plan!

SELECT
	AVG(wc.DistanceKM) AS DistanceAverageKM,
	wc.WarehouseID
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID 
	CROSS APPLY Shipping.ClosestWarehouse(l.PhysicalLocation) wc
	WHERE oh.OrderDate='2016-08-24'
GROUP BY wc.WarehouseID;

--EXEC Demo.CreateOrdersForDay @Orderdate='2016-08-25'

SELECT
	AVG(wc.DistanceKM),
	wc.WarehouseID
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID 
	CROSS APPLY Shipping.ClosestWarehouse(l.PhysicalLocation) wc
WHERE oh.OrderDate='2016-08-25'
GROUP BY wc.WarehouseID;


GO
