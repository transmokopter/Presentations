USE master;
GO
ALTER DATABASE StatsDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE StatsDemo;
GO

CREATE DATABASE [StatsDemo];
go
ALTER DATABASE [StatsDemo] SET COMPATIBILITY_LEVEL = 100
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
CREATE SCHEMA Production;
GO
CREATE SCHEMA Sales;
GO
CREATE SCHEMA Shipping;
GO
CREATE SCHEMA Demo;

GO
CREATE FUNCTION Demo.GetSameDate(@dt date)
RETURNS TABLE
AS RETURN SELECT @dt as dt;


GO


CREATE FUNCTION Demo.GetSameDateScalar(@dt DATE)
RETURNS DATE
AS
BEGIN
	RETURN @dt;
END;
GO
CREATE TABLE Shipping.Locations(
	LocationID int identity(1,1) CONSTRAINT PK_Shipping_Locations PRIMARY KEY CLUSTERED,
	LocationName varchar(100),
	PhysicalLocation geography
);
CREATE SPATIAL INDEX ix_PhysicalLocation ON Shipping.Locations(PhysicalLocation);
CREATE TABLE Shipping.Warehouse(
	WarehouseID int identity(1,1) CONSTRAINT PK_Shipping_Warehouse PRIMARY KEY CLUSTERED,
	WarehouseName varchar(100),
	LocationID int CONSTRAINT FK_Warehouse_Locations FOREIGN KEY REFERENCES Shipping.Locations(LocationID)
);
CREATE INDEX ix_LocationID ON Shipping.Warehouse(LocationID);

CREATE TABLE Sales.Customer(
	CustomerID int identity(1,1) CONSTRAINT PK_Sales_Customer PRIMARY KEY CLUSTERED,
	CustomerName varchar(100)
);


CREATE TABLE Sales.CustomerAddress(
	CustomerAddressID int identity(1,1) CONSTRAINT PK_Sales_CustomerAddress PRIMARY KEY CLUSTERED,
	CustomerID int CONSTRAINT FK_CustomerAddress_Customer FOREIGN KEY REFERENCES Sales.Customer(CustomerID),
	LocationID int CONSTRAINT FK_CustomerAddress_Locations FOREIGN KEY REFERENCES Shipping.Locations(LocationID)
);
CREATE INDEX ix_CustomerID ON Sales.CustomerAddress(CustomerID);
CREATE INDEX ix_LocationID ON Sales.CustomerAddress(LocationID);



CREATE TABLE Sales.OrderHeader(
	OrderHeaderID int identity(1,1) CONSTRAINT PK_Sales_OrderHeader PRIMARY KEY CLUSTERED,
	OrderDate date CONSTRAINT DF_OrderHeader_OrderDate DEFAULT(CURRENT_TIMESTAMP),
	CustomerID int CONSTRAINT FK_OrderHeader_Customer FOREIGN KEY REFERENCES Sales.Customer(CustomerID),
	CustomerAddressID int CONSTRAINT FK_OrderHeader_CustomerAddress FOREIGN KEY REFERENCES Sales.CustomerAddress(CustomerAddressID),
	IsOrderShipped bit CONSTRAINT DF_OrderHeader_IsOrderShipped DEFAULT(0),
	OrderHeaderDiscount numeric(5,2),
	InvoiceAmount money
);
CREATE INDEX ix_OrderDate ON Sales.OrderHeader(OrderDate) INCLUDE(CustomerID);
CREATE INDEX ix_IsOrderShipped ON Sales.OrderHeader(IsOrderShipped);
CREATE INDEX ix_InvoiceAmount ON Sales.OrderHeader(InvoiceAmount);
CREATE INDEX ix_CustomerID ON Sales.OrderHeader(CustomerID);
CREATE INDEX ix_CustomerAddressID ON Sales.OrderHeader(CustomerAddressID);

GO
CREATE FUNCTION Shipping.ClosestWarehouse(@TargetLocation as geography)
RETURNS TABLE
AS
	RETURN
		SELECT TOP(1) @TargetLocation.STDistance(wl.PhysicalLocation) as DistanceKM, w.WarehouseID
		FROM Shipping.Warehouse w
		INNER JOIN Shipping.Locations wl ON w.LocationID = wl.LocationID 
		ORDER BY @TargetLocation.STDistance(wl.PhysicalLocation);
GO


INSERT Shipping.Locations(
	LocationName,
	PhysicalLocation)
VALUES	('Berlin, Germany',geography::Point(52.52000659999999,13.404953999999975,4326)),
		('Paris, France',geography::Point(48.85661400000001,2.3522219000000177,4326)),
		('London, United Kingdom',geography::Point(51.5073509,-0.12775829999998223,4326)),
		('Edsbyn, Sweden',geography::Point(61.37502739999999,15.8182726,4326)),
		('Sandviken, Sweden',geography::Point(60.621607,16.775918000000047,4326)),
		('Lidköping, Sweden',geography::Point(58.5035047,13.157076800000027,4326)),
		('Bollnäs, Sweden',geography::Point(61.34837950000001,16.394268499999953,4326));
insert shipping.locations(locationname,physicallocation)
  SELECT coalesce([AddressLine1],'') + ',' + coalesce([AddressLine2],'') + ',' + coalesce([City], '') + ',' + coalesce(r.CountryRegionName ,''),
  a.SpatialLocation
  FROM [AdventureWorks2014].[Person].[Address] a
  inner join AdventureWorks2014.person.vStateProvinceCountryRegion r ON a.StateProvinceID = r.StateProvinceID
where r.StateProvinceID in (
  select stateprovinceid from adventureworks2014.person.vStateProvinceCountryRegion where TerritoryID in (7,8,10)
);
  
INSERT Sales.Customer (CustomerName)
select top 5627 FirstName + ' ' + LastName from adventureworks2014.person.person
order by newid();
with cte1 as (
	select customerid,
	row_number() over(order by customerid) as rownum
	from sales.customer 
), cte2 as (
	select locationid,
	row_number() over(order by newid()) as rownum
	from shipping.locations where locationid>7
)
INSERT Sales.CustomerAddress (CustomerID, LocationID)
select cte1.CustomerID, cte2.LocationID
FROM cte1 INNER JOIN CTE2 ON CTE1.rownum = CTE2.rownum;

INSERT Shipping.Warehouse (WarehouseName, LocationID)
VALUES	('Berlin',1),
		('Paris',2),
		('London',3);


GO
CREATE TABLE Demo.Today(dt date PRIMARY KEY CLUSTERED);
INSERT Demo.Today (dt) SELECT CURRENT_TIMESTAMP;
GO
CREATE FUNCTION Demo.GetToday()
RETURNS TABLE
AS 
	RETURN SELECT TOP 1 dt FROM Demo.Today ORDER BY dt DESC;
GO
--Create orders


CREATE OR ALTER PROC Demo.CreateOrdersForDay
(
 @orderdate DATE,
 @numOrders INT = 50000
)
AS
BEGIN;
	WITH CTE_Customers AS(
		SELECT TOP(@numOrders) c.CustomerID FROM Sales.Customer c 
		CROSS JOIN Sales.Customer c2
		ORDER BY NEWID()
	)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
	SELECT @orderdate,c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,@orderdate))
	FROM CTE_Customers c
	INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID
	OPTION(RECOMPILE)
	;
END
GO

WITH CTE_Numbers AS(
	SELECT n FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(n)
),CTE_Numbers2 AS(
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) as n
	FROM CTE_Numbers n
	CROSS JOIN CTE_Numbers n2
	CROSS JOIN CTE_Numbers n3
),CTE_Dates AS(
	SELECT TOP(100) DATEADD(DAY,-1*n,cast('2016-08-25' AS date)) as OrderDate
	FROM CTE_Numbers2 ORDER BY n 
),CTE_Customers AS(
		SELECT TOP(50000) c.CustomerID FROM Sales.Customer c 
		CROSS JOIN Sales.Customer c2
		ORDER BY NEWID()
	)INSERT Sales.OrderHeader (OrderDate,CustomerID,CustomerAddressID,IsorderShipped,OrderHeaderDiscount)
	SELECT OrderDate,c.CustomerID,ca.CustomerAddressID,0,RAND(DATEPART(second,CURRENT_TIMESTAMP)*DATEPART(DAY,OrderDate))
	FROM CTE_Customers c
	INNER JOIN Sales.CustomerAddress ca ON c.CustomerID = ca.CustomerID
	CROSS JOIN CTE_Dates;

GO
