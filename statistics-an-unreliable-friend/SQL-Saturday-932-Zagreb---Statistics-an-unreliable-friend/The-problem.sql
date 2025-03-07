USE StatsDemo

--This is what Ola Hallengrens solution will do on a nightly basis
UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;
SET STATISTICS IO, TIME ON;

--Remember to enable actual execution plan!
DECLARE @s NVARCHAR(MAX)=N'
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
	WHERE oh.OrderDate=''2016-08-24''
GROUP BY wc.WarehouseID;'
EXEC sp_executesql @statement = @s;

GO
EXEC Demo.CreateOrdersForDay @Orderdate='2016-08-25'
GO
DECLARE @s NVARCHAR(MAX)=N'
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
	WHERE oh.OrderDate=''2016-08-25''
GROUP BY wc.WarehouseID;'
EXEC sp_executesql @s;


GO
