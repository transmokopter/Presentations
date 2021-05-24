USE StatsDemo
--DEMO PREPARATION
--Make sure we have perfect statistics to begin with
UPDATE STATISTICS Sales.OrderHeader WITH FULLSCAN;

--Now add some data which is outside of the statistics
EXEC demo.CreateOrdersForDay
	@orderdate = '2016-08-25' -- date
  , @numOrders = 12500 -- int;

--Examine the statistics
DBCC SHOW_STATISTICS('sales.OrderHeader', 'ix_orderdate')
SELECT * FROM sys.stats WHERE object_id=OBJECT_ID('sales.orderheader');
SELECT * FROM sys.dm_db_stats_properties(OBJECT_ID('sales.OrderHeader'),2);
SELECT * FROM sys.dm_db_stats_histogram(OBJECT_ID('sales.OrderHeader'),2);
SELECT * FROM sys.dm_db_stats_properties_internal(OBJECT_ID('sales.OrderHeader'),2);



-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- DEMO1 simple cardinality estimation. One predicate. 
-- Predicate values inside and outside histogram. SQL Server 2012 and SQL Server 2019.
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

--SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;
GO
SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-24' 
OPTION
(RECOMPILE);

--SQL Server 2019
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;

SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-24' 
OPTION(RECOMPILE);

SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-24'  
OPTION(USE HINT('FORCE_LEGACY_CARDINALITY_ESTIMATION'), RECOMPILE);

--Where does that estimation come from??


SELECT * FROM sys.dm_db_stats_properties(OBJECT_ID('sales.OrderHeader'),2);

SELECT (modification_counter * 1.0) / steps + 12496 
FROM sys.dm_db_stats_properties(OBJECT_ID('sales.OrderHeader'),2);

--Now let's examine values outside of histogram
--SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;
SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-25'
OPTION(RECOMPILE);


--SQL Server 2019
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;
GO
SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-25'
OPTION(RECOMPILE);

SELECT COUNT(*) FROM Sales.OrderHeader 
WHERE OrderDate = '2016-08-25'
OPTION(RECOMPILE, USE HINT('FORCE_LEGACY_CARDINALITY_ESTIMATION'));

--1123,51???????????? 

SELECT SQRT(rows+modification_counter) FROM sys.dm_db_stats_properties(OBJECT_ID('sales.OrderHeader'),2);

--Yeah, cuz this makes a lot of sense, right?

--And to make things more fun, this won't be consistent either. If SQRT(total rowcount) is a higher value then whatever 
--is returned from the "main path" of cardinality estimation, the "main path" value will be used.
--Main path for single column predicate with value outside  histogram, when there are changed rows since updated statistics: Use density from statistics object.
DBCC SHOW_STATISTICS('sales.orderheader','ix_orderdate') WITH DENSITY_VECTOR;
SELECT 0.01 * (rows+modification_counter) FROM sys.dm_db_stats_properties(OBJECT_ID('sales.OrderHeader'),2);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--DEMO2 more complex cardinality estimation, 
--two or more columns involved in predicates. Still single table
--Covering index
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

--SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;
GO
SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-24' AND customerid = 3933 OPTION(RECOMPILE);
--2,49271. That's not a very even number, is it?
--Let's look at individual estimations
SELECT COUNT(*) FROM sales.OrderHeader WHERE CustomerID = 3933; --213,929   <<<-----
SELECT COUNT(*) FROM sales.OrderHeader WHERE OrderDate = '2016-08-24' --12621;

SELECT 213.929 * (12622.0 / (rows + modification_counter))
FROM sys.dm_db_stats_properties(OBJECT_ID('sales.orderheader'),2)
--No, that's 2.139...

--Let's look at density vector
DBCC SHOW_STATISTICS('sales.orderheader','ix_orderdate') WITH DENSITY_VECTOR;

--Ah, covering index. So density for OrderDate combined with CustomerID:

SELECT 1.994511E-06 * (rows)
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.OrderHeader'),2);
--This time, modification_counter is not considered.


ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;
GO
SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-24' AND customerid = 3933 OPTION(RECOMPILE);

SELECT 1.994511E-06 * (rows + modification_counter)
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.OrderHeader'),2);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- DEMO3 two or more predicates, single table, no covering indexes
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

--SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 110;
GO
SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-24' AND CustomerAddressID = 5442 OPTION(RECOMPILE);

--211.474 estimated rows for customeraddressid=5442
--12621 estimated rows for orderdate='2016-08-24'
--2.11442 rows estimated to come out from the Hash Match operator
SELECT 211.474 * (12621.0 / (rows + modification_counter))
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.OrderHeader'),2)

--When date is outside the histogram
SET STATISTICS IO ON;
SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-25' AND CustomerAddressID = 5442 OPTION(RECOMPILE);

--Oops!


--SQL Server 2019
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 150;
GO

SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-24' AND CustomerAddressID = 5442 OPTION(RECOMPILE);

SELECT 213.588 * (12621.0 / (rows + modification_counter))
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.OrderHeader'),2);
--No, that's not it anymore.



--Let's go crazy

-- Start the session
SELECT COUNT(*)
FROM Sales.OrderHeader
WHERE OrderDate = '2016-08-24' AND CustomerAddressID = 5442 OPTION(RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 2363);

--213.588 estimated rows for customeraddressid=5442  <<-- This is different from SQL 2012
--12621 estimated rows for orderdate='2016-08-24'
--2.24029 rows estimated to come out from the Hash Match operator <<-- This is different from SQL 2012
SELECT 213.588 * 12621 * 8.08138e-07 --  <<<--- density vector for PK
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.OrderHeader'),2);

--Here's another fun one with new CE
SELECT COUNT(*) FROM sales.OrderHeader WHERE IsOrderShipped=1 OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 2363);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- DEMO4. Let's do "real" joins!
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 110;
GO
SET STATISTICS IO ON;
GO
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate='2016-08-24'
GROUP BY l.CountryRegionCode
OPTION(RECOMPILE);

SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate='2016-08-25'
GROUP BY l.CountryRegionCode
OPTION(RECOMPILE);


--SQL Server 2019
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 150;
GO
SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate='2016-08-24'
GROUP BY l.CountryRegionCode
OPTION(RECOMPILE);

SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate='2016-08-25'
GROUP BY l.CountryRegionCode
OPTION(RECOMPILE);

--Look at the orderheader estimation!!

BEGIN TRAN 

DELETE sales.OrderHeader WHERE OrderDate<'2016-07-15'
UPDATE STATISTICS sales.OrderHeader WITH FULLSCAN;
EXEC demo.CreateOrdersForDay
	@orderdate = '2016-08-26' -- date
  , @numOrders = 12500 -- int

SELECT
	AVG(OrderHeaderDiscount) As DiscountAverage,
	l.CountryRegionCode
FROM
	Sales.OrderHeader oh
	INNER JOIN Sales.CustomerAddress ca
	ON oh.CustomerID = ca.CustomerID 
	INNER JOIN Shipping.Locations l
	ON ca.LocationID = l.LocationID
	WHERE oh.OrderDate='2016-08-26'
GROUP BY l.CountryRegionCode
OPTION(RECOMPILE);
rollback