--Parametrize
DECLARE @dt date='2016-08-25';
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
WHERE oh.OrderDate=@dt 
GROUP BY wc.WarehouseID;
--Though on first compilation, plan is chosen based on parameter value.
GO
--Get date from function
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
	WHERE oh.OrderDate = Demo.GetSameDateScalar('2016-08-25')
GROUP BY wc.WarehouseID;
GO
--TRACEFLAG 2389
--Requires three consecutive statistics updates to find out about the ascending key
--TRACEFLAG 2388 shows information about columns branded ascending
DBCC TRACEON(2389);
DBCC TRACEON(2388);
--Trace flag list
--Google for SQLSERVICE TRACE FLAGS and the third hit or so is Steinar Andersens blog post about trace flags
--Page will tell you if the trace flag is documented or not, and what it does.
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
WITH CTE_Customers AS(
	SELECT TOP(50) c.CustomerID FROM Sales.Customer c 
	CROSS JOIN Sales.Customer c2
	ORDER BY NEWID()
)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
SELECT '2016-08-26',c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,'2016-08-26'))
FROM CTE_Customers c
INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID;
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
WITH CTE_Customers AS(
	SELECT TOP(50) c.CustomerID FROM Sales.Customer c 
	CROSS JOIN Sales.Customer c2
	ORDER BY NEWID()
)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
SELECT '2016-08-27',c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,'2016-08-27'))
FROM CTE_Customers c
INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID;
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
WITH CTE_Customers AS(
	SELECT TOP(50) c.CustomerID FROM Sales.Customer c 
	CROSS JOIN Sales.Customer c2
	ORDER BY NEWID()
)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
SELECT '2016-08-28',c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,'2016-08-28'))
FROM CTE_Customers c
INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID;
GO
UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;
GO
WITH CTE_Customers AS(
	SELECT TOP(50) c.CustomerID FROM Sales.Customer c 
	CROSS JOIN Sales.Customer c2
	ORDER BY NEWID()
)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
SELECT '2016-08-29',c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,'2016-08-29'))
FROM CTE_Customers c
INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID;
GO
UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;

DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');
--See, ascending
GO
--We already know it's ascending, now we want to see the histograms again with show_statistics
DBCC TRACEOFF(2388);
DBCC SHOW_STATISTICS('Sales.OrderHeader','ix_OrderDate') WITH HISTOGRAM;
--Note the hightest RANGE_HI_KEY
--Let's insert a higher OrderDate
EXEC Demo.CreateOrdersForDay @orderdate = '2016-08-30';
--Look at statistics
DBCC SHOW_STATISTICS('Sales.OrderHeader','ix_OrderDate') WITH HISTOGRAM;
--Let's query the data again
DBCC FREEPROCCACHE;

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
WHERE oh.OrderDate='2016-08-30'
GROUP BY wc.WarehouseID;
GO
--Voila!

DBCC TRACEOFF(2389);
DBCC TRACESTATUS(-1);

--the Voldemort solution, not gonna show you..



DBCC FREEPROCCACHE
--UPGRADE to SQL 2014
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 110;
--Test 
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
WHERE oh.OrderDate='2016-08-30'
GROUP BY wc.WarehouseID;


--But how about missing key, which is not ascending value?
EXEC demo.createordersforday @orderdate='2016-09-02';

UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;

EXEC demo.createordersforday @orderdate='2016-09-01';
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;
GO
DBCC FREEPROCCACHE;

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
WHERE oh.OrderDate='2016-09-01'
GROUP BY wc.WarehouseID;
GO

--Upgrade again, to SQL 2016
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 130;
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;


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
WHERE oh.OrderDate='2016-09-01'
GROUP BY wc.WarehouseID;
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;


--Optimize for unknown. Requires parameter.
DECLARE @dt date='2016-09-01';
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
WHERE oh.OrderDate=@dt 
GROUP BY wc.WarehouseID
OPTION(OPTIMIZE FOR(@dt UNKNOWN));


--Silver bullet?