ALTER DATABASE rbar SET COMPATIBILITY_LEVEL=100
GO
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cust;
DROP TABLE IF EXISTS #t;
GO
GO
GO
GO
WITH ten AS (
	SELECT i FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1))t(i)
),thousands AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) n 
	FROM ten t1
	CROSS JOIN ten t2 
	CROSS JOIN ten t3 
	CROSS JOIN ten t4 
	CROSS JOIN ten t5
	CROSS JOIN ten t6
)SELECT * INTO #t FROM thousands;
CREATE CLUSTERED INDEX ix_t ON #t(n);
GO
SELECT TOP 300 n AS CustId,CONCAT('Customer_',n) AS customername
INTO cust 
FROM #t 
ORDER BY n;

ALTER TABLE cust ALTER COLUMN custid INT NOT NULL;
GO
ALTER TABLE cust ADD CONSTRAINT pk_cust PRIMARY KEY CLUSTERED(custid);
GO
SELECT 
	n AS orderid,
	CAST(DATEADD(DAY,-(n%30 +1),CURRENT_TIMESTAMP) AS DATE) AS OrderDate,
	ROW_NUMBER() OVER(ORDER BY (SELECT NULL))%300 + 1 AS custid
INTO Orders
FROM #t 
;
ALTER TABLE Orders ALTER COLUMN OrderID INT NOT NULL;
ALTER TABLE Orders ALTER COLUMN CustID INT NOT NULL;
go
ALTER TABLE Orders ADD CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED(OrderID);
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Cust FOREIGN KEY(custid) REFERENCES Cust(custid);
GO
CREATE INDEX ix_OrderDateCustid ON Orders(OrderDate,CustId);

----DONE INSERTING DATA


SELECT o.OrderDate, o.OrderId, o.custid, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=CAST(DATEADD(DAY,-1,CURRENT_TIMESTAMP) AS date);

GO
DECLARE @maxorderid INT;
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate),@maxorderid=MAX(orderid) FROM orders;
INSERT Orders  
SELECT ROW_NUMBER() OVER(ORDER BY OrderID)+@maxorderid, DATEADD(DAY,1,orderdate), custid 
FROM orders WHERE orderdate=@maxorderdate;



GO
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(RECOMPILE);
SET STATISTICS IO OFF;

UPDATE STATISTICS orders WITH FULLSCAN;
GO

DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(RECOMPILE);
SET STATISTICS IO OFF;
GO

DECLARE @maxorderid INT;
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate),@maxorderid=MAX(orderid) FROM orders;
INSERT Orders  
SELECT ROW_NUMBER() OVER(ORDER BY OrderID)+@maxorderid, DATEADD(DAY,1,orderdate), custid 
FROM orders WHERE orderdate=@maxorderdate;
GO

DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(RECOMPILE);
SET STATISTICS IO OFF;
GO

--Try to get rid of RBAR plan
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER MERGE JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(RECOMPILE);
SET STATISTICS IO OFF;
GO

--One more option
DECLARE @maxorderdate DATE;
DECLARE @optimizefor DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET @optimizefor = DATEADD(DAY,-7,@maxorderdate);
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(RECOMPILE, OPTIMIZE FOR (@maxorderdate=@optimizefor));
SET STATISTICS IO OFF;

GO
--Huh?
--No, must hard code value with optimize for
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(OPTIMIZE FOR(@maxorderdate='2019-10-01'));
SET STATISTICS IO OFF;

--But bad idea to hard code a value, that value might fall out of the table later on.
--Optimize for unknown will force using density vector in the statistics object
DECLARE @maxorderdate DATE;
SELECT @maxorderdate=MAX(orderdate) FROM orders;
SET STATISTICS IO ON;
SELECT o.OrderDate, o.OrderId, c.CustomerName
FROM Orders o 
INNER JOIN Cust c ON o.custid = c.custid 
WHERE o.OrderDate=@maxorderdate OPTION(OPTIMIZE FOR(@maxorderdate unknown));
SET STATISTICS IO OFF;



