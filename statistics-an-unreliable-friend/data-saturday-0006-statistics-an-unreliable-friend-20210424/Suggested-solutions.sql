USE StatsDemo
SET STATISTICS IO, TIME ON
--Turn on actual plan

--Parametrize
--This is roughly what any sanely programmed application would send
DECLARE @dt date='2016-08-25';
DECLARE @s NVARCHAR(MAX)=N'
--Parametrized query
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sp_executesql @statement = @s, @params = N'@dt date', @dt = @dt;
GO
DECLARE @dt date='2016-08-24';
DECLARE @s NVARCHAR(MAX)=N'
--Parametrized query
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sp_executesql @statement = @s, @params = N'@dt date', @dt = @dt;


GO
--Get date from function
DECLARE @dt DATE = '2016-08-25';
DECLARE @s NVARCHAR(MAX) = N'
--Get date from scalar function
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	--Never ever remove the stupid function call. We need it to cheat the optimizer.
	WHERE oh.OrderDate = Demo.GetSameDateScalar(@dt) --look here
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params = N'@dt date', @dt = @dt;

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

EXEC demo.CreateOrdersForDay @orderdate = '2016-08-26',@numOrders = 50 -- date
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
EXEC demo.CreateOrdersForDay @orderdate = '2016-08-27',@numOrders = 50 -- date
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
EXEC demo.CreateOrdersForDay @orderdate = '2016-08-28',@numOrders = 50 -- date
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO
EXEC demo.CreateOrdersForDay @orderdate = '2016-08-29',@numOrders = 50 -- date
GO
UPDATE STATISTICS Sales.orderHeader WITH FULLSCAN;
GO


DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');
--See, ascending
GO
DBCC SHOW_STATISTICS('Sales.OrderHeader','ix_OrderDate') WITH HISTOGRAM;
--We already know it's ascending, now we want to see the histograms again with show_statistics
DBCC TRACEOFF(2388);
DBCC SHOW_STATISTICS('Sales.OrderHeader','ix_OrderDate') ;
--Note the hightest RANGE_HI_KEY
--Let's insert a higher OrderDate
EXEC Demo.CreateOrdersForDay @orderdate = '2016-08-30';
--Look at statistics

DBCC SHOW_STATISTICS('Sales.OrderHeader','ix_OrderDate') WITH HISTOGRAM;
--Let's query the data again

DECLARE @dt DATE = '2016-08-30';
DECLARE @s NVARCHAR(MAX) = N'
--with traceflags 2388 and 2389
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params=N'@dt date', @dt = @dt;
GO


--DBCC TRACEOFF(2389);
--DBCC TRACESTATUS(-1);

--the Voldemort solution, not gonna show you..



--UPGRADE to SQL 2014
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 120;
GO
--Test

DECLARE @dt DATE = '2016-08-30';
DECLARE @s NVARCHAR(MAX) = N'
--with sql2014
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params=N'@dt date', @dt = @dt;


--More on that estimate in the CE-demo...

GO
DECLARE @dt DATE='2016-08-30';
DECLARE @s NVARCHAR(MAX)=N'SELECT COUNT(*) FROM sales.OrderHeader AS OH WHERE orderdate=@dt option(recompile)';
EXEC sys.sp_executesql @statement = @s, @params = N'@dt date', @dt = @dt;


--UPGRADE to SQL 2016
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 130;
--Test
GO
DECLARE @dt DATE = '2016-08-30';
DECLARE @s NVARCHAR(MAX) = N'
--sql2016
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params=N'@dt date', @dt = @dt;

DBCC SHOW_STATISTICS([sales.OrderHeader], ix_orderdate)
--UPGRADE to SQL 2017
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 140;
--Test
GO
DECLARE @dt DATE = '2016-08-30';
DECLARE @s NVARCHAR(MAX) = N'
--sql2017
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params=N'@dt date', @dt = @dt;

DBCC SHOW_STATISTICS([sales.OrderHeader], ix_orderdate)


--UPGRADE to SQL 2019
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 150;
--Test
GO
DECLARE @dt DATE = '2016-08-30';
DECLARE @s NVARCHAR(MAX) = N'
--sql2019
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode;'
EXEC sys.sp_executesql @statement = @s, @params=N'@dt date', @dt = @dt;


GO


--Parametrized with optimize for unknown. 
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=140
DECLARE @dt date='2016-08-30';
DECLARE @s NVARCHAR(MAX)='
SELECT
	--low
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate=@dt
GROUP BY l.CountryRegionCode
OPTION(OPTIMIZE FOR(@dt UNKNOWN));'
EXEC sp_executesql @statement = @s, @params = N'@dt date', @dt = @dt;



--Silver bullet? It depends :)