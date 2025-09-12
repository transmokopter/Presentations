USE master 
go
IF DB_ID('TemporalDb') IS NOT NULL
BEGIN
	ALTER DATABASE TemporalDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TemporalDb;
END
GO
CREATE DATABASE TemporalDb;
GO
USE TemporalDb;
GO
-- New table
CREATE TABLE dbo.Pricelist(
	ProductId INT NOT NULL CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
	ListPrice MONEY NOT NULL 
);


GO
-- Not happy, we need history of prices
DROP TABLE IF EXISTS dbo.Pricelist;
GO



CREATE TABLE dbo.Pricelist(
	ProductId INT NOT NULL CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
	ListPrice MONEY NOT NULL,
	RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
	RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME(RowStart,RowEnd)
)WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.PricelistHistory));

GO

-- Let's add some data
INSERT dbo.Pricelist (ProductId, ListPrice)
VALUES
	(1, 10),
	(2,20),
	(3,30);

-- Check table
SELECT * FROM dbo.PriceList;

-- Prices are wrong, let's fix that
UPDATE dbo.Pricelist SET ListPrice = ListPrice * 1.1 WHERE ProductId = 1;



-- Check table again
SELECT * FROM dbo.PriceList;




-- Check prices at a certain time
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME AS OF '2025-09-11 21:48:00';

-- All occurances within a given time period 
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME BETWEEN '2025-09-11 21:47:00' AND '2025-09-11 21:49:00';

-- Changes in a certain period
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME CONTAINED IN('2025-09-11 21:47:00','2025-09-11 21:49:00');

-- Check prices that were valid in a date range
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME FROM '2025-09-11 21:47:00' TO '2025-09-11 21:49:00'
-- Notice that price for ProductId = 1 was valid twice within this time range, first between 
-- time a and b, and then between time b and indefinitely

SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME FROM '2025-09-11 21:47:00' TO '2025-09-11 21:48:00'
-- Notice that the NEW price for ProductId = 1 was never valid in the above given time range

-- Give me everything
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME ALL;


-- Drop table, we want to start over
DROP TABLE dbo.Pricelist;
-- Can't drop a table that's system versioned



ALTER TABLE dbo.Pricelist SET(SYSTEM_VERSIONING=OFF);
DROP TABLE dbo.Pricelist;
DROP TABLE dbo.PricelistHistory;



-- Existing table, make it temporal 
CREATE TABLE dbo.Pricelist(
	ProductId INT NOT NULL CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
	ListPrice MONEY 
);
GO
-- Let's add some data again
INSERT dbo.Pricelist (ProductId, ListPrice)
VALUES
	(1, 10),
	(2,20),
	(3,30);
GO



-- Now make this table system-versioned
ALTER TABLE dbo.Pricelist ADD 
 RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, --NOT NULL! 
 RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,   --NOT NULL!
 PERIOD FOR SYSTEM_TIME(RowStart,RowENd);
GO
-- No, NOT NULL doesn't work without a default
ALTER TABLE dbo.Pricelist ADD 
 RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL CONSTRAINT DF_Pricelist_RowStart DEFAULT(CURRENT_TIMESTAMP), -- Use any default you want. Perhaps 1900-01-01 is better? 
 RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL CONSTRAINT DF_Pricelist_RowEnd DEFAULT('9999-12-31 23:59:59.9999999'),   -- This must be exactly this value!
 PERIOD FOR SYSTEM_TIME(RowStart,RowENd);

-- And now we can make the table system versioned
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING=ON(HISTORY_TABLE=dbo.PricelistHistory));
GO


-- One more scenario, let's cleanup and start over
ALTER TABLE dbo.Pricelist SET(SYSTEM_VERSIONING=OFF);
DROP TABLE dbo.Pricelist;
DROP TABLE dbo.PricelistHistory;
GO


-- Existing table with versioning inside the same table, common pattern
CREATE TABLE dbo.Pricelist(
 ProductId INT NOT NULL , 
 ListPrice MONEY NOT NULL,
 ValidFrom DATETIME NOT NULL CONSTRAINT DF_Pricelist_ValidFrom DEFAULT CURRENT_TIMESTAMP,
 ValidTo DATETIME,
 CONSTRAINT PK_Pricelist PRIMARY KEY(ProductId,ValidFrom)
);

INSERT dbo.Pricelist (ProductId, ListPrice)
VALUES
	(1, 10),
	(2,20),
	(3,30);
GO

SELECT * FROM dbo.Pricelist;

 -- Change a price
 DECLARE @dt DATETIME;
 SET @dt=CURRENT_TIMESTAMP;
 -- Update current price row to invalidate it
 UPDATE dbo.Pricelist SET ValidTo=@dt WHERE ProductId = 1 AND ValidTo IS NULL;
 -- Insert a new valid row
 INSERT dbo.Pricelist (ProductId, ListPrice, ValidFrom) VALUES(1,11, @dt);

SELECT * FROM dbo.Pricelist;

-- Get the current price
SELECT * FROM dbo.Pricelist WHERE ValidTo IS NULL;

-- System time AS OF equivalent in the old days
DECLARE @asof DATETIME = '2025-09-11 22:10:27';
SELECT * FROM dbo.Pricelist pl WHERE pl.ValidFrom <= @asof AND ISNULL(pl.ValidTo,@asof)>= @asof 
GO 
DECLARE @asof DATETIME = '2025-09-11 22:10:44';
SELECT * FROM dbo.Pricelist pl WHERE pl.ValidFrom <= @asof AND ISNULL(pl.ValidTo,@asof)>= @asof 
GO 

-- Transform this table into one that works with system-versioning
ALTER TABLE dbo.Pricelist DROP CONSTRAINT PK_Pricelist;
ALTER TABLE dbo.Pricelist DROP CONSTRAINT DF_Pricelist_ValidFrom;
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidFrom DATETIME2(7) ;
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidTo DATETIME2(7) ;

-- Fix values to align with system-versioning
UPDATE dbo.Pricelist SET ValidTo='9999-12-31 23:59:59.99999999' WHERE ValidTo IS NULL;

-- Fix NOT NULL properties
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidFrom DATETIME2 NOT NULL;
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidTo DATETIME2 NOT NULL;

-- Create history table
CREATE TABLE dbo.PricelistHistory(
 ProductID INT NOT NULL,
 ListPrice MONEY NOT NULL,
 ValidFrom DATETIME2(7) NOT NULL,
 ValidTo DATETIME2(7) NOT NULL
);


-- Move rows to history table
INSERT dbo.PricelistHistory(ProductId, ListPrice,ValidFrom,ValidTo)
SELECT ProductId,ListPrice, ValidFrom, ValidTO 
FROM dbo.Pricelist WHERE ValidTo<'9999-12-31 23:59:59.9999999';

DELETE dbo.Pricelist WHERE ValidTo<'9999-12-31 23:59:59.9999999';



-- Update times, they should be UTC-time
UPDATE dbo.Pricelist SET ValidFrom = DATEADD(HOUR,-1,ValidFrom)

-- History table too.
UPDATE dbo.PricelistHistory SET ValidFrom = DATEADD(HOUR,-1,ValidFrom), ValidTo = DATEADD(HOUR,-1,ValidTo);
GO

-- Now we can activate system versioning
ALTER TABLE dbo.Pricelist ADD PERIOD FOR SYSTEM_TIME(ValidFrom,ValidTo);
ALTER TABLE dbo.Pricelist ADD CONSTRAINT PK_Pricelist PRIMARY KEY(ProductId);
ALTER TABLE dbo.Pricelist SET(SYSTEM_VERSIONING=ON(HISTORY_TABLE=dbo.PricelistHistory)); 
GO
UPDATE dbo.Pricelist SET ListPrice = 111 WHERE ProductId = 1;
SELECT * FROM dbo.PriceList 

SELECT * FROM dbo.PricelistHistory

-- Object explorer.
-- Look into tables, structure in OE
-- Look at indexes

-- Let's checkout execution plan:
SELECT * FROM dbo.Pricelist FOR SYSTEM_TIME AS OF '2025-09-11 23:00:00'

-- Clean up after our mess
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING=OFF);
DROP TABLE dbo.PricelistHistory;
DROP TABLE dbo.Pricelist;
