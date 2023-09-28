USE master
GO
IF DB_ID('WideWorldImporters') IS NOT NULL
BEGIN
	ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END
GO
DROP DATABASE IF EXISTS WideWorldImporters;
GO

RESTORE DATABASE WideWorldImporters FROM DISK=N'/var/opt/mssql/data/WideWorldImporters-Full.bak'
WITH 
	MOVE 'WWI_Primary' TO N'/var/opt/mssql/data/WideWorldImporters.mdf',
	MOVE 'WWI_UserData' TO N'/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
	MOVE 'WWI_Log' TO N'/var/opt/mssql/data/WideWorldImporters.ldf',
	MOVE 'WWI_InMemory_Data_1' TO N'/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1';
GO
USE WideWorldImporters
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL=160;
GO
ALTER DATABASE WideWorldImporters
SET QUERY_STORE = ON (
    OPERATION_MODE = READ_WRITE,
    QUERY_CAPTURE_MODE = AUTO
);
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET ROW_MODE_MEMORY_GRANT_FEEDBACK = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_MEMORY_GRANT_FEEDBACK = ON;
GO
--As of this writing, documentation says to use MEMORY_GRANT_FEEDBACK_PERCENTILE which yields an "Incorrect syntax" error
--https://learn.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing-feedback?view=sql-server-ver16#cardinality-estimation-ce-feedback
ALTER DATABASE SCOPED CONFIGURATION SET MEMORY_GRANT_FEEDBACK_PERCENTILE_GRANT = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MEMORY_GRANT_FEEDBACK_PERSISTENCE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET CE_FEEDBACK = ON;
GO

--Create skew in Sales.Orders for CustomerId = 90
--Add 1 500 000 orders for CustomerId = 90
WITH CTE AS (
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
	FROM
	(
		SELECT t.n FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(n)
		CROSS JOIN
		(VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t1(n)
		CROSS JOIN
		(VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t2(n)
		CROSS JOIN
		(VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t3(n)
	)t(n)
)INSERT Sales.Orders
(
    CustomerID,
    SalespersonPersonID,
    PickedByPersonID,
    ContactPersonID,
    BackorderOrderID,
    OrderDate,
    ExpectedDeliveryDate,
    CustomerPurchaseOrderNumber,
    IsUndersupplyBackordered,
    Comments,
    DeliveryInstructions,
    InternalComments,
    PickingCompletedWhen,
    LastEditedBy,
    LastEditedWhen
)
SELECT 
    O.CustomerID,
    O.SalespersonPersonID,
    O.PickedByPersonID,
    O.ContactPersonID,
    O.BackorderOrderID,
    O.OrderDate,
    O.ExpectedDeliveryDate,
    O.CustomerPurchaseOrderNumber,
    O.IsUndersupplyBackordered,
    O.Comments,
    O.DeliveryInstructions,
    O.InternalComments,
    O.PickingCompletedWhen,
    O.LastEditedBy,
    O.LastEditedWhen
FROM Sales.Orders AS O
CROSS JOIN CTE
WHERE O.CustomerID = 90;


--Parameter Sensitive Plan Optimization

--Repo the problem that PSP Optimization is trying to solve
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF;
DBCC FREEPROCCACHE;
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
CREATE OR ALTER PROC Sales.GetOrdersForCustomer(
	@CustomerId int
)
AS
BEGIN
SELECT * FROM Sales.Orders AS O WHERE O.CustomerID = @CustomerId;
END;
GO
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
GO
SET STATISTICS IO ON;
EXEC Sales.GetOrdersForCustomer @CustomerId = 90;
GO


ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON;
DBCC FREEPROCCACHE;
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;

GO
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
EXEC Sales.GetOrdersForCustomer @CustomerId = 1060;
GO
EXEC Sales.GetOrdersForCustomer @CustomerId = 90;
GO












--Memory Grant Feedback
CREATE OR ALTER PROC Sales.GetOrdersAndOrderlinesForCustomer(
	@CustomerId int
)
AS
SELECT * FROM Sales.Orders AS O INNER HASH JOIN Sales.OrderLines AS OL ON OL.OrderID = O.OrderID
WHERE O.CustomerID = @CustomerId;
GO
--Execute a few times and observe memory grant
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=1060;


EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
DBCC FREEPROCCACHE; -- This would evict memory grant information in previous versions of SQL Server
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
--Execute a few times and observe memory grant
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
DBCC FREEPROCCACHE;
GO
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
GO
DBCC FREEPROCCACHE;
GO
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
GO
DBCC FREEPROCCACHE;
GO
EXEC Sales.GetOrdersAndOrderlinesForCustomer @CustomerId=90;
GO
ALTER DATABASE AdventureWorks2014 SET QUERY_STORE CLEAR;
DBCC FREEPROCCACHE;

