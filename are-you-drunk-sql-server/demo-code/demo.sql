USE Statsdemo;
--Demo 1
SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName='Volvo'
GROUP BY Color;

SELECT COUNT(*),Color 
FROM dbo.Car 
WHERE BrandName='Ferrari'
GROUP BY Color;









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

-- Let's try it in SQL Server 2022 mode
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL=160;
DBCC FREEPROCCACHE;
ALTER DATABASE StatsDemo SET QUERY_STORE CLEAR;
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON;

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
DECLARE @BrandName VARCHAR(50), @Color VARCHAR(50);
SET @BrandName = 'Ferrari';
SET @Color = 'Blue';
DECLARE @sql NVARCHAR(MAX)=N'SELECT BrandName, Color 
FROM dbo.Car 
WHERE BrandName=@BrandName AND Color=@Color;';
EXEC sp_executesql @sql,N'@BrandName varchar(50),@Color varchar(50)',@BrandName,@Color;
