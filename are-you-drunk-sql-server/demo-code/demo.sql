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
SELECT * FROM dbo.car WHERE brandname='Toyota' AND color='white'
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

GO
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color;'
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
GO


-- Demo 4, get into the head of SQL Server!
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


-- Slides