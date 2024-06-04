USE master;
GO
IF DB_ID('StatsDemo') IS NOT NULL
	ALTER DATABASE StatsDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS StatsDemo;
GO

CREATE DATABASE [StatsDemo];
GO
ALTER DATABASE [StatsDemo] SET COMPATIBILITY_LEVEL = 160
ALTER DATABASE [StatsDemo] SET RECOVERY SIMPLE WITH NO_WAIT
ALTER DATABASE [StatsDemo] MODIFY FILE ( NAME = N'StatsDemo', SIZE = 2097152KB , FILEGROWTH = 1048576KB )
ALTER DATABASE [StatsDemo] MODIFY FILE ( NAME = N'StatsDemo_log', SIZE = 10485760KB , FILEGROWTH = 1048576KB )
USE StatsDemo;
GO
--These are instance wide configurations. Be careful not to run this in a shared environment without really knowing
--what the configurations do
exec sp_configure 'show advanced options',1;
reconfigure;
exec sp_configure 'optimize for ad hoc workloads',1;
reconfigure
exec sp_configure 'cost threshold for parallelism',100;
reconfigure;
exec sp_configure 'show advanced options',0;
reconfigure;
GO
CREATE TABLE dbo.CarAggregate(
	BrandName VARCHAR(50) NOT NULL,
	CarCount INT NOT NULL
);

INSERT dbo.CarAggregate
(
    BrandName,
    CarCount
)
VALUES
	('Ferrari',1916),
	('Audi',294284),
	('BMW',327706),
	('Ford',387397),
	('Kia',300941),
	('Mercedes-Benz',369790),
	('Peugot',244042),
	('Renault',274733),
	('Toyota',469989),
	('Volkswagen',995292),
	('Volvo',1381028),
	('Abarth',1076),
	('ABT',900),
	('AC Cars',218),
	('Acadian',19);


CREATE TABLE dbo.Car(
	CarId INT IDENTITY(1,1) CONSTRAINT PK_Car PRIMARY KEY CLUSTERED,
	BrandName VARCHAR(50) NOT NULL,
	Color VARCHAR(50) NOT NULL
);

INSERT dbo.Car(BrandName,Color)
SELECT CA.BrandName, CHOOSE(CASE WHEN brandname='Ferrari' THEN 1 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT NULL))%4+1 END,'Red','Blue','Grey','Green')
FROM dbo.CarAggregate AS CA
CROSS APPLY GENERATE_SERIES(1,CA.CarCount,1) gs;

CREATE NONCLUSTERED INDEX ix_Car_BrandName ON dbo.Car(BrandName) WITH(DATA_COMPRESSION=PAGE);


GO
ALTER DATABASE [StatsDemo] SET COMPATIBILITY_LEVEL = 110
GO

ALTER DATABASE StatsDemo SET QUERY_STORE CLEAR;
DBCC FREEPROCCACHE
GO

CREATE EVENT SESSION [query_optimizer_estimate_cardinality] ON SERVER
ADD EVENT sqlserver.query_optimizer_estimate_cardinality
 (  
 ACTION (sqlserver.sql_text)  
  WHERE (  
  sql_text LIKE '%dbo.Car%'
  )  
 )
ALTER EVENT SESSION [query_optimizer_estimate_cardinality] ON SERVER  STATE=START;



