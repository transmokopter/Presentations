USE TemporalDb;
GO
-- One more scenario, let's cleanup and start over
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING = OFF);
DROP TABLE dbo.Pricelist;
DROP TABLE dbo.PricelistHistory;
GO


-- Existing table with versioning inside the same table, common pattern
CREATE TABLE dbo.Pricelist
(
    ProductId INT NOT NULL,
    ListPrice MONEY NOT NULL,
    ValidFrom DATETIME NOT NULL
        CONSTRAINT DF_Pricelist_ValidFrom
            DEFAULT CURRENT_TIMESTAMP,
    ValidTo DATETIME,
    CONSTRAINT PK_Pricelist
        PRIMARY KEY (
                        ProductId,
                        ValidFrom
                    )
);

INSERT dbo.Pricelist
(
    ProductId,
    ListPrice
)
VALUES
(1, 10),
(2, 20),
(3, 30);
GO

SELECT *
FROM dbo.Pricelist;

-- Change a price
DECLARE @dt DATETIME;
SET @dt = CURRENT_TIMESTAMP;
-- Update current price row to invalidate it
UPDATE dbo.Pricelist
SET ValidTo = @dt
WHERE ProductId = 1
      AND ValidTo IS NULL;
-- Insert a new valid row
INSERT dbo.Pricelist
(
    ProductId,
    ListPrice,
    ValidFrom
)
VALUES
(1, 11, @dt);

SELECT *
FROM dbo.Pricelist;

-- Get the current price
SELECT *
FROM dbo.Pricelist
WHERE ValidTo IS NULL;

-- System time AS OF equivalent in the old days
DECLARE @asof DATETIME = DATEADD(MINUTE, -1, CURRENT_TIMESTAMP);
SELECT *
FROM dbo.Pricelist pl
WHERE pl.ValidFrom <= @asof
      AND ISNULL(pl.ValidTo, @asof) >= @asof;
GO
DECLARE @asof DATETIME = DATEADD(MINUTE, -2, CURRENT_TIMESTAMP);
SELECT *
FROM dbo.Pricelist pl
WHERE pl.ValidFrom <= @asof
      AND ISNULL(pl.ValidTo, @asof) >= @asof;
GO

-- Transform this table into one that works with system-versioning
ALTER TABLE dbo.Pricelist DROP CONSTRAINT PK_Pricelist;
ALTER TABLE dbo.Pricelist DROP CONSTRAINT DF_Pricelist_ValidFrom;
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidFrom DATETIME2(7);
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidTo DATETIME2(7);

-- Fix values to align with system-versioning
UPDATE dbo.Pricelist
SET ValidTo = '9999-12-31 23:59:59.99999999'
WHERE ValidTo IS NULL;

-- Fix NOT NULL properties
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidFrom DATETIME2 NOT NULL;
ALTER TABLE dbo.Pricelist ALTER COLUMN ValidTo DATETIME2 NOT NULL;

-- Create history table
CREATE TABLE dbo.PricelistHistory
(
    ProductID INT NOT NULL,
    ListPrice MONEY NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);
-- Need clustered index to make retention period thingee work
CREATE CLUSTERED INDEX ixc_PricelistHistory
ON dbo.PricelistHistory (
                            ValidTo,
                            ValidFrom
                        )
WITH (DATA_COMPRESSION = PAGE);
-- Move rows to history table
INSERT dbo.PricelistHistory
(
    ProductID,
    ListPrice,
    ValidFrom,
    ValidTo
)
SELECT ProductId,
       ListPrice,
       ValidFrom,
       ValidTo
FROM dbo.Pricelist
WHERE ValidTo < '9999-12-31 23:59:59.9999999';

DELETE dbo.Pricelist
WHERE ValidTo < '9999-12-31 23:59:59.9999999';

SELECT *
FROM dbo.Pricelist AS P;
SELECT *
FROM dbo.PricelistHistory AS PH;
-- Update times, they should be UTC-time
UPDATE dbo.Pricelist
SET ValidFrom = DATEADD(HOUR, -1, ValidFrom);

-- History table too.
UPDATE dbo.PricelistHistory
SET ValidFrom = DATEADD(HOUR, -1, ValidFrom),
    ValidTo = DATEADD(HOUR, -1, ValidTo);
GO

-- Now we can activate system versioning
ALTER TABLE dbo.Pricelist
ADD PERIOD FOR SYSTEM_TIME(ValidFrom, ValidTo);
ALTER TABLE dbo.Pricelist
ADD CONSTRAINT PK_Pricelist
    PRIMARY KEY (ProductId);

--Notice the retention period
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING = ON (
    HISTORY_TABLE=dbo.PricelistHistory, HISTORY_RETENTION_PERIOD=2 DAYS));
GO
UPDATE dbo.Pricelist
SET ListPrice = 111
WHERE ProductId = 1;
SELECT *
FROM dbo.Pricelist;

SELECT *
FROM dbo.PricelistHistory;
