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

CREATE TABLE dbo.AfterMarketStuff(
	AfterMarketStuffId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AfterMarketStuff PRIMARY KEY CLUSTERED,
	Thing VARCHAR(50) NOT NULL,
	YearsBetweenShift NUMERIC(4,1) NOT NULL,
	Price NUMERIC(16,2) NOT NULL,
	BrandName VARCHAR(50) NULL,
	Color VARCHAR(50) NULL
);

CREATE INDEX ix_AfterMarketStuff_BrandName ON dbo.AfterMarketStuff(BrandName) WITH(DATA_COMPRESSION=PAGE);
CREATE INDEX ix_AfterMarketStuff_Color ON dbo.AfterMarketStuff(Color) WITH(DATA_COMPRESSION=PAGE);

WITH things AS(
	SELECT t.thing,t.yearsbetween,t.listprice FROM (
		VALUES
			('GearBoxOil',3,100),
			('MotorOil',1,70),
			('Paint',15,1000),
			('BrakePads',3,200),
			('WipersFront',0.5,50),
			('WipersBack',0.5,50),
			('WindShield',10,500),
			('Headlights',2,100),
			('RearLights',2,100),
			('IndicatorLights',2,100),
			('CoolingMedia',5,500)
		) t(thing,yearsbetween,listprice)
) 
INSERT dbo.AfterMarketStuff
(
    Thing,
    BrandName,
    Color,
    Price,
    YearsBetweenShift
)
SELECT 
	things.thing,
	CA.BrandName,
	CASE WHEN things.thing='Paint' THEN CHOOSE(t.value,'Red','Blue','Grey','Green') ELSE NULL END AS Color,
	(CUME_DIST() OVER(ORDER BY CA.CarCount)+1) * things.listprice AS BrandPrice,
	(CUME_DIST() OVER(ORDER BY CA.CarCount)+0.1)*things.yearsbetween AS YearsBetweenShift
FROM things CROSS JOIN dbo.CarAggregate AS CA
CROSS APPLY(SELECT value FROM generate_series(1,CASE WHEN things.thing='Paint' THEN 4 ELSE 1 END,1) t) t(value)
;
INSERT dbo.AfterMarketStuff
(
    Thing,
    YearsBetweenShift,
    Price,
    BrandName,
    Color
)
VALUES
(   'WasherFluid',   -- Thing - varchar(50)
    0.25,    -- YearsBetweenShift - numeric(4, 1)
    10,    -- Price - numeric(16, 2)
    NULL, -- BrandName - varchar(50)
    NULL  -- Color - varchar(50)
);

CREATE TABLE dbo.AfterMarketCar(
	AfterMarketCarId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AfterMarketCar PRIMARY KEY CLUSTERED,
	AfterMarketStuffId INT NOT NULL,
	CarId INT NOT NULL,
	DateOfOccurance DATE NOT NULL
);
GO
INSERT dbo.AfterMarketCar(
	AfterMarketStuffId,
	CarId,
	DateOfOccurance
)
SELECT
	AMS.AfterMarketStuffId,
	C.CarId,
	DATEADD(DAY,-1*(CarId%997),CURRENT_TIMESTAMP)
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.Car AS C ON c.BrandName = AMS.BrandName AND c.Color = AMS.Color
WHERE C.CarId%7=0
;
INSERT dbo.AfterMarketCar(
	AfterMarketStuffId,
	CarId,
	DateOfOccurance
)
SELECT
	AMS.AfterMarketStuffId,
	C.CarId,
	DATEADD(DAY,-1*(CarId%1009),CURRENT_TIMESTAMP)
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.Car AS C ON c.BrandName = AMS.BrandName AND AMS.Color IS NULL
WHERE C.CarId%5=0
;
INSERT dbo.AfterMarketCar(
	AfterMarketStuffId,
	CarId,
	DateOfOccurance
)
SELECT
	AMS.AfterMarketStuffId,
	C.CarId,
	DATEADD(DAY,-1*(CarId%1013),CURRENT_TIMESTAMP)
FROM dbo.AfterMarketStuff AS AMS
INNER JOIN dbo.Car AS C ON AMS.BrandName IS NULL
WHERE C.CarId%3=0
;

CREATE INDEX ix_AfterMarketCar_CarId ON dbo.AfterMarketCar(CarId) WITH(DATA_COMPRESSION=PAGE);
CREATE INDEX ix_AfterMarketCar_DateOfOccurance ON dbo.AfterMarketCar(DateOfOccurance) WITH(DATA_COMPRESSION=PAGE);
CREATE INDEX ix_AfterMarketCar_AfterMarketStuffId ON dbo.AfterMarketCar(AfterMarketStuffId) WITH(DATA_COMPRESSION=PAGE);





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



GO
ALTER DATABASE [StatsDemo] SET COMPATIBILITY_LEVEL = 110
GO
