USE Statsdemo;
-- Let's start simple
SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName='Volvo'
GROUP BY Color;

SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName='Ferrari'
GROUP BY Color;

-- SQL Server uses statistics
SELECT name,stats_id FROM sys.stats AS S WHERE object_id=OBJECT_ID('dbo.Car');
SELECT 
	DDSH.step_number,
	DDSH.range_high_key,
	DDSH.range_rows,
	DDSH.equal_rows,
	DDSH.distinct_range_rows,
	DDSH.average_range_rows
FROM sys.dm_db_stats_histogram(OBJECT_ID('dbo.Car'),2) AS DDSH

--Sometimes, histogram will not be used. Instead, SQL Server will look at density vector
DBCC SHOW_STATISTICS(Car,ix_Car_BrandName)
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



--Demo 2 - Parameter Sniffing

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO

DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari'
DECLARE @sql NVARCHAR(MAX)=N'SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName=@BrandName
GROUP BY Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;
GO
DBCC FREEPROCCACHE
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
WHERE BrandName=@BrandName
GROUP BY Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50)',@BrandName;

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
WHERE BrandName=@BrandName AND Color=@Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;

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
WHERE BrandName=@BrandName AND Color=@Color;'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
GO

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

-- Demo 5, get into the head of SQL Server!
-- We stay on SQL Server 2019 mode but we use OPTION(RECOMPILE)
-- Open live output from XEvent session
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Volvo';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color OPTION(RECOMPILE);'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color OPTION(RECOMPILE);'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
GO


