USE master 
GO
DROP DATABASE IF EXISTS AscendingKey;
CREATE DATABASE AscendingKey;
GO
ALTER DATABASE AscendingKey SET COMPATIBILITY_LEVEL=110;
GO
USE AscendingKey;
--Setup Customers TABLE;
SELECT TOP 300 firstname,lastname,middlename,birthdate,EmailAddress,ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS customerid 
  INTO dbo.Customer
FROM AdventureWorksDW2014.dbo.DimCustomer WHERE birthdate<'1980-01-01';

ALTER TABLE dbo.Customer ALTER COLUMN CustomerID INT NOT NULL;
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED(CustomerID);
SELECT * FROM dbo.Customer;

--Setup orders table;
CREATE TABLE dbo.SalesOrderHeader (OrderHeaderID BIGINT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, SalesAmount MONEY,OrderDate DATE, OrderNumber VARCHAR(30),CustomerID INT NOT NULL);
CREATE INDEX ix_CustomerID ON dbo.SalesOrderHeader(CustomerID);
ALTER TABLE dbo.SalesOrderHeader ADD CONSTRAINT FK_SalesOrderHeader_Customer FOREIGN KEY (CUstomerID) REFERENCES dbo.Customer(CustomerID);
CREATE CLUSTERED INDEX ix_OrderDate ON dbo.SalesOrderHeader(OrderDate,OrderHeaderID);

WITH Orders AS (
	SELECT TOP 100 * FROM AdventureWorksDW2014.dbo.FactInternetSales
	WHERE salesorderlinenumber=1
),tens as(
	SELECT n FROM(VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(n)
),thousands AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
	FROM tens c1
	CROSS JOIN Tens c2
	CROSS JOIN Tens c3
	CROSS JOIN Tens c4 
),dates AS (
	SELECT TOP 365 DATEADD(DAY,-n,CURRENT_TIMESTAMP) AS orderdate FROM thousands ORDER BY n
)INSERT dbo.SalesOrderHeader(SalesAmount,CustomerID,OrderDate)
	SELECT o.SalesAmount, c.CustomerID,d.orderdate
	FROM Orders o 
	CROSS JOIN dates d
	CROSS JOIN dbo.customer c;

UPDATE STATISTICS dbo.SalesOrderHeader WITH FULLSCAN;
UPDATE STATISTICS dbo.Customer WITH FULLSCAN;

SET STATISTICS IO ON;

SELECT SUM(soh.SalesAmount), c.firstname, c.lastname, c.middlename 
FROM dbo.SalesOrderHeader soh
INNER JOIN dbo.Customer c ON soh.CustomerID=c.CustomerID 
WHERE soh.OrderDate='2019-05-03'
GROUP BY c.firstname,c.lastname,c.middlename;





WITH Orders AS (
	SELECT TOP 100 * FROM AdventureWorksDW2014.dbo.FactInternetSales
	WHERE salesorderlinenumber=1
)INSERT dbo.SalesOrderHeader(SalesAmount,CustomerID,OrderDate)
	SELECT o.SalesAmount, c.CustomerID,'2019-05-04'
	FROM Orders o 
	CROSS JOIN dbo.customer c;
	SET STATISTICS TIME ON;
SELECT soh.*, c.firstname, c.lastname, c.middlename 
FROM dbo.SalesOrderHeader soh
INNER JOIN dbo.Customer c ON soh.CustomerID=c.CustomerID 
WHERE soh.OrderDate='2019-05-04'

UPDATE STATISTICS dbo.SalesOrderHeader WITH FULLSCAN;

SELECT soh.*, c.firstname, c.lastname, c.middlename 
FROM dbo.SalesOrderHeader soh
INNER JOIN dbo.Customer c ON soh.CustomerID=c.CustomerID 
WHERE soh.OrderDate='2019-05-04'

GO
WITH Orders AS (
	SELECT TOP 100 * FROM AdventureWorksDW2014.dbo.FactInternetSales
	WHERE salesorderlinenumber=1
)INSERT dbo.SalesOrderHeader(SalesAmount,CustomerID,OrderDate)
	SELECT o.SalesAmount, c.CustomerID,'2019-05-05'
	FROM Orders o 
	CROSS JOIN dbo.customer c;
GO
SELECT soh.*, c.firstname, c.lastname, c.middlename 
FROM dbo.SalesOrderHeader soh
INNER JOIN dbo.Customer c ON soh.CustomerID=c.CustomerID 
WHERE soh.OrderDate='2019-05-05'

DBCC SHOW_STATISTICS('dbo.SalesOrderHeader','ix_orderdate');

