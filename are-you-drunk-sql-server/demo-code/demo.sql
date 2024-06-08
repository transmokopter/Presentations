USE Statsdemo;
SET NOCOUNT ON;
SELECT D.name, D.compatibility_level FROM sys.databases AS D


-- Let's start by examining our data:
SELECT COUNT(*) AS CountCars, Color, BrandName FROM dbo.Car 
GROUP BY Color, BrandName 
ORDER BY BrandName, Color;

SELECT * FROM dbo.AfterMarketStuff AS AMS
ORDER BY Thing,BrandName, Color;

SELECT 
	COUNT(*) AS AfterMarketCount, C.BrandName, C.Color, AMS.Thing, SUM(AMS.Price) AS GrossSales
FROM dbo.Car AS C
	INNER JOIN dbo.AfterMarketStuff AS AMS ON (AMS.BrandName = C.BrandName OR AMS.BrandName IS NULL) AND (AMS.Color = C.Color OR AMS.Color IS NULL)
	INNER JOIN dbo.AfterMarketCar AS AMC ON AMC.AfterMarketStuffId = AMS.AfterMarketStuffId AND AMC.CarId = C.CarId
WHERE AMC.DateOfOccurance > DATEADD(YEAR,-1,CURRENT_TIMESTAMP)
GROUP BY C.BrandName, C.Color, AMS.Thing
ORDER BY C.BrandName, C.Color, AMS.Thing

-- Clear Plan Cache
DBCC FREEPROCCACHE;

-- Let's start simple
SET STATISTICS IO ON;
SELECT COUNT(*) AS CarCount,Color 
FROM dbo.Car 
WHERE BrandName='Volvo'
GROUP BY Color;
SET STATISTICS IO OFF;

SET STATISTICS IO ON;
SELECT COUNT(*) AS CarCount,Color 
FROM dbo.Car 
WHERE BrandName='Ferrari'
GROUP BY Color;
SET STATISTICS IO OFF;

-- SQL Server uses statistics
SELECT name,stats_id FROM sys.stats AS S WHERE object_id=OBJECT_ID('dbo.Car');

-- Stats ID 2 is an index, Stats ID 3 is Column Statistics, and I happen to know it's for the Color column.
--Let's look into them

SELECT 
	DDSH.step_number,
	DDSH.range_high_key,
	DDSH.range_rows,
	DDSH.equal_rows,
	DDSH.distinct_range_rows,
	DDSH.average_range_rows
FROM sys.dm_db_stats_histogram(OBJECT_ID('dbo.Car'),2) AS DDSH

SELECT 
	DDSH.step_number,
	DDSH.range_high_key,
	DDSH.range_rows,
	DDSH.equal_rows,
	DDSH.distinct_range_rows,
	DDSH.average_range_rows
FROM sys.dm_db_stats_histogram(OBJECT_ID('dbo.Car'),3) AS DDSH


--Sometimes, histogram will not be used. Instead, SQL Server will look at density vector
DBCC SHOW_STATISTICS(Car,ix_Car_BrandName) WITH DENSITY_VECTOR
DBCC SHOW_STATISTICS(Car,_WA_Sys_00000003_36B12243) WITH DENSITY_VECTOR
-- All density = Count of distinct values / total number of rows

--Let's create a multi-column index
CREATE INDEX ix_Car_BrandName_ColorON dbo.Car (BrandName, Color)WITH (DATA_COMPRESSION=PAGE);
GO

SELECT * FROM dbo.car WHERE brandname='Toyota' AND color='Blue' OPTION(RECOMPILE);
-- Estimation: 88548,8 rows
-- 
DBCC SHOW_STATISTICS(Car,ix_Car_BrandName_Color)

-- Density of BrandName, Color = 0.01754386
-- Total number of rows in table = 5049331
SELECT 5049331 * 0.01754386

DROP INDEX ix_Car_BrandName_Color ON dbo.Car

--Let's dive into the Cars' per color query again:
SET STATISTICS IO ON;
SELECT COUNT(*) AS CarCount,Color 
FROM dbo.Car 
WHERE BrandName='Ferrari'
GROUP BY Color;
SET STATISTICS IO OFF;

-- Why estimate four rows out of the aggreage, when there are only Red Ferraris?




-- Getting SQL Server to use density vector instead of histogram
-- Optimize for Unknown
DECLARE @BrandName VARCHAR(50)='Volvo'
EXEC sp_executesql N'SELECT COUNT(*), Color
FROM dbo.Car
WHERE BrandName=@BrandName
GROUP BY Color
OPTION(OPTIMIZE FOR(@BrandName UNKNOWN));',N'@BrandName varchar(50)',@BrandName;
GO
-- Or introduce implicit conversion on the data side of things
DECLARE @BrandName NVARCHAR(50)=N'Volvo'
EXEC sp_executesql N'SELECT COUNT(*), Color
FROM dbo.Car
WHERE BrandName=@BrandName
GROUP BY Color;',N'@BrandName nvarchar(50)',@BrandName;
GO

--Slides

--Demo 2 - Parameter Sniffing

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
SET STATISTICS IO ON
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO OFF
GO

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
SET STATISTICS IO ON
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO OFF
GO
-- Let's start over, and run the Ferrari query first
DBCC FREEPROCCACHE
GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
SET STATISTICS IO ON
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO OFF
GO

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
SET STATISTICS IO ON
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO OFF

GO

-- Let's try it in SQL Server 2019 mode
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;
DBCC FREEPROCCACHE;
ALTER DATABASE StatsDemo SET QUERY_STORE CLEAR;

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
-- Here''s a comment
WHERE BrandName=@BrandName
GROUP BY Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO

-- Another query
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari'
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo'
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO
--Back to SQL Server 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;
ALTER DATABASE StatsDemo SET QUERY_STORE CLEAR;
DBCC FREEPROCCACHE;

GO


-- Slides

--Demo 3 - Combine predicates


DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
GO


-- 345078
DBCC SHOW_STATISTICS('dbo.Car','ix_Car_BrandName')
-- Selectivity for BrandName = 'Volvo' = 1381028/5049331.0
SELECT 1381028/5049331.0

SELECT * FROM sys.stats s WHERE s.object_id=OBJECT_ID('dbo.Car');
DBCC SHOW_STATISTICS('dbo.Car','_WA_Sys_00000003_36B12243')
--Selectivity for predicate Color='Blue' is 1265478/5049331.0
SELECT 1261677/5049331.0

-- Exponential backoff came in SQL Server 2014 and we run in 2012 mode, so we're doing it the old-school way
-- Selectivity predicate1 * selectivity predicate2
SELECT 0.249870131 * 0.273507124 * COUNT(*) FROM dbo.Car AS C

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color OPTION(RECOMPILE);';
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color OPTION(RECOMPILE);';
SET STATISTICS IO ON
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
SET STATISTICS IO OFF


GO

-- And in SQL Server 2019?
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;
DBCC FREEPROCCACHE;
ALTER DATABASE StatsDemo SET QUERY_STORE CLEAR;
GO


DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color;'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;

-- 659831
DBCC SHOW_STATISTICS('dbo.Car','ix_Car_BrandName')
-- Selectivity for BrandName = 'Volvo' = 1381028/5049331.0
SELECT 1381028/5049331.0

SELECT * FROM sys.stats s WHERE s.object_id=OBJECT_ID('dbo.Car');
DBCC SHOW_STATISTICS('dbo.Car','_WA_Sys_00000003_36B12243')
--Selectivity for predicate Color='Blue' is 1265478/5049331.0
SELECT 1261677/5049331.0

-- Exponential backoff is used.
-- Selectivity of most selective predicate * SQRT(second most selective predicate)
SELECT 0.249870131 * SQRT(0.273507124) * COUNT(*) FROM dbo.Car AS C

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color OPTION(RECOMPILE);'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
GO

--Slides

--Demo 4, more complexity: Joins
SET STATISTICS IO ON;
SELECT SUM(AMS.Price) AS TotalRevenue, C.BrandName, AMS.Thing, AMS.Color
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.AfterMarketCar AS AMC ON AMS.AfterMarketStuffId = AMC.AfterMarketStuffId
INNER JOIN dbo.Car C ON AMC.CarId = C.CarId
WHERE AMC.DateOfOccurance >='2024-01-03' AND AMC.DateOfOccurance<='2024-03-03'
AND AMS.Thing='WasherFluid'
GROUP BY C.BrandName, AMS.Thing, AMS.Color;
SET STATISTICS IO OFF;

-- SQL Server selects the density from the stats for AfterMarketStuffId in AfterMarketCar
-- And then multiplies 756110 with the selectivity of AfterMarketStuffId in that statistics object
SELECT * FROM sys.stats WHERE object_id=OBJECT_ID('AfterMarketCar')
SELECT * FROM dbo.AfterMarketStuff AS AMS WHERE AMS.Thing='Washerfluid'
-- 211
DBCC SHOW_STATISTICS('AfterMarketCar','ix_AfterMarketCar_AfterMarketStuffId')
-- 1683110 rows in AfterMarketCar for WasherFluid
-- But SQL Server use density vector instead, because at this point, it can't know what ID will be returned.
SELECT 0.004830918*12503103
-- And so it thinks only 60401 rows are this specific AfterMarketStuffId

-- Let's look at other options the optimizer could have chosen later on.


SET STATISTICS IO ON;
SELECT SUM(AMS.Price) AS TotalRevenue, C.BrandName, AMS.Thing, AMS.Color
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.AfterMarketCar AS AMC ON AMS.AfterMarketStuffId = AMC.AfterMarketStuffId
INNER JOIN dbo.Car C ON AMC.CarId = C.CarId
WHERE AMC.DateOfOccurance >='2024-01-03' AND AMC.DateOfOccurance<='2024-03-03'
AND AMS.Thing='Windshield'
GROUP BY C.BrandName, AMS.Thing, AMS.Color;
SET STATISTICS IO OFF;

-- Demo 5, Missing statistics
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=160;
GO
DELETE car WHERE brandname='SAAB'
UPDATE STATISTICS dbo.Car WITH FULLSCAN;

INSERT INTO dbo.Car
(
    BrandName,
    Color
)
SELECT 'SAAB', 'Pink'
FROM generate_series(1,50000);
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;

SELECT * FROM dbo.Car WHERE brandname='SAAB';


DECLARE @BrandName VARCHAR(50)='SAAB';
SET STATISTICS IO on
EXEC sp_executesql N'SELECT * FROM dbo.Car WHERE BrandName = @BrandName',N'@BrandName varchar(50)',@BrandName;
EXEC sp_executesql N'SELECT * FROM dbo.Car WHERE BrandName = @BrandName OPTION(OPTIMIZE FOR(@BrandName UNKNOWN))',N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO off

ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=150;
GO
SELECT * FROM dbo.Car WHERE brandname='SAAB';
DECLARE @BrandName VARCHAR(50)='SAAB';
SET STATISTICS IO on
EXEC sp_executesql N'SELECT * FROM dbo.Car WHERE BrandName = @BrandName',N'@BrandName varchar(50)',@BrandName;
EXEC sp_executesql N'SELECT * FROM dbo.Car WHERE BrandName = @BrandName OPTION(OPTIMIZE FOR(@BrandName UNKNOWN))',N'@BrandName varchar(50)',@BrandName;
SET STATISTICS IO off
GO

-- Ascending key
SELECT MAX(carid) FROM dbo.Car
DBCC FREEPROCCACHE
ALTER TABLE dbo.car rebuild
SELECT * FROM dbo.Car WHERE CarId>5049331 OPTION(RECOMPILE)
-- Why 15.000 though?
-- Not sure, but it's pretty close to 0,3% of the table cardinality..

-- Let's go crazy!!!
SELECT * FROM dbo.Car WHERE CarId>1115160398 OPTION(RECOMPILE)

-- Ok, so asking for all rows higher than ANY number outside the histogram gives a 15k estimate

SELECT * FROM dbo.Car WHERE CarId>=5160398 AND CarId<=5161398;

-- Why 4.500 though?
SELECT 0.3*15000;


ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=110;
SELECT * FROM dbo.Car WHERE CarId>=5160398 AND CarId<=5161398;



-- Demo 6, get into the head of SQL Server!
-- We stay on SQL Server 2019 mode but we use OPTION(RECOMPILE)
-- Open live output from XEvent session
SELECT * FROM dbo.car C
INNER JOIN dbo.AfterMarketCar AS AMC ON C.CarId = AMC.CarId
WHERE AMC.AfterMarketStuffId=11 OPTION(RECOMPILE)

SELECT * FROM dbo.Car C WHERE BrandName='Ferrari' AND Color='Blue';

SELECT SUM(AMS.Price) AS TotalRevenue, C.BrandName, AMS.Thing, AMS.Color
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.AfterMarketCar AS AMC ON AMS.AfterMarketStuffId = AMC.AfterMarketStuffId
INNER JOIN dbo.Car C ON AMC.CarId = C.CarId
WHERE AMC.DateOfOccurance >='2024-01-03' AND AMC.DateOfOccurance<='2024-03-03'
AND AMS.Thing='WasherFluid'
GROUP BY C.BrandName, AMS.Thing, AMS.Color
OPTION(RECOMPILE);



--Now start the feed
SELECT * FROM dbo.Car WHERE CarId>10000000 OPTION(RECOMPILE)
