USE master 
GO
IF DB_ID('SqlServerWorstPractices') IS NOT NULL
BEGIN
	ALTER DATABASE SqlServerWorstPractices SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END
GO
DROP DATABASE IF EXISTS SqlServerWorstPractices;
GO
CREATE DATABASE SqlServerWorstPractices;
GO
ALTER DATABASE SqlServerWorstPractices SET AUTO_SHRINK ON;
ALTER DATABASE SqlServerWorstPractices SET RECOVERY SIMPLE;
GO
USE SqlServerWorstPractices
GO
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;
GO
CREATE TABLE dbo.SalesOrder(
	SalesOrderId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SalesOrder PRIMARY KEY CLUSTERED,
	OrderDate DATETIME2(7) NOT NULL CONSTRAINT DF_SalesOrder_OrderDate DEFAULT(SYSDATETIME()),
	OrderCurrency CHAR(3) NOT NULL,
	OrderValue MONEY
);


CREATE NONCLUSTERED INDEX ix_SalesOrder_OrderDate ON dbo.SalesOrder(OrderDate);
CREATE NONCLUSTERED INDEX ix_SalesOrder_OrderCurrency ON dbo.SalesOrder(OrderCurrency);

CREATE TABLE dbo.Currency(CurrencyCode CHAR(3) NOT NULL CONSTRAINT PK_Currency PRIMARY KEY CLUSTERED);

CREATE TABLE dbo.CurrencyRate(
	CurrencyCode CHAR(3) NOT NULL ,
	CurrencyDate DATE NOT NULL,
	Rate NUMERIC(10,4) NOT NULL,
	CONSTRAINT PK_CurrencyRate PRIMARY KEY CLUSTERED(CurrencyCode,CurrencyDate)
 )
 GO
 DECLARE @currencies NVARCHAR(MAX);
 SELECT @currencies = BulkColumn FROM OPENROWSET(
   BULK '/var/opt/mssql/data/currencies_vs_sek.csv',
   SINGLE_CLOB
) AS DATA;
WITH cte AS (
SELECT ss.value AS rowdata, ss2.value AS columndata,ss2.ordinal FROM STRING_SPLIT(@currencies,CHAR(10)) AS SS
CROSS APPLY STRING_SPLIT(ss.value,';',1) AS SS2
WHERE ss.value NOT LIKE 'Datum%'
)
INSERT dbo.CurrencyRate
(
    CurrencyCode,
    CurrencyDate,
    Rate
)
SELECT 
CAST(RIGHT(cte1.columndata,3) AS CHAR(3)) AS CurrencyCode,
CAST(cte2.columndata AS DATE) AS CurrencyDate,
CAST(REPLACE(REPLACE(cte3.columndata,CHAR(13),''),',','.') AS NUMERIC(10,4)) AS rate
FROM cte cte1 
INNER JOIN cte cte2 ON cte1.rowdata=cte2.rowdata
INNER JOIN cte cte3 ON cte2.rowdata=cte3.rowdata
WHERE cte1.ordinal=3 AND cte2.ordinal=1 AND cte3.ordinal=4 AND cte3.columndata NOT LIKE 'N/A%'
GO

WITH cte AS (SELECT DISTINCT currencydate FROM currencyRate)
INSERT dbo.CurrencyRate
(
    CurrencyCode,
    CurrencyDate,
    Rate
)
SELECT 'SEK',cte.CurrencyDate, 1
FROM cte 
GO
ALTER TABLE dbo.SalesOrder ADD CONSTRAINT FK_SalesOrder_Currency FOREIGN KEY(OrderCurrency) REFERENCES dbo.Currency(CurrencyCode);
GO
INSERT dbo.Currency
(
    CurrencyCode
)
SELECT DISTINCT CurrencyCode FROM dbo.CurrencyRate AS CR;
GO
ALTER TABLE dbo.CurrencyRate ADD CONSTRAINT FK_CurrencyRate_Currency FOREIGN KEY(CurrencyCode) REFERENCES dbo.Currency(CurrencyCode);
GO
WITH ten AS(
	SELECT 1 AS n 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1 
	UNION ALL SELECT 1
),
currencies AS(
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) rn, CurrencyCode 
	FROM dbo.Currency AS C
),
million AS(
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) rn 
	FROM ten CROSS JOIN ten t2 CROSS JOIN ten t3 CROSS JOIN ten t4 CROSS JOIN ten t5 CROSS JOIN ten t6
),millionorders AS(
SELECT DATEADD(DAY,RAND(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)))*-3000,CURRENT_TIMESTAMP) AS OrderDate, c.CurrencyCode,RAND()*1000 AS OrderValue
FROM million 
INNER JOIN currencies c ON million.rn%c.rn=0

)
--SELECT * FROM millionorders;
INSERT dbo.SalesOrder
(
    OrderDate,
    OrderCurrency,
    OrderValue
)
SELECT OrderDate,CurrencyCode,OrderValue FROM millionorders;
