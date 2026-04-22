USE TemporalDb;
GO
-- Retention
-- Create table the old way to be able to set specific dates for ValidFrom
-- Just run through the whole thing
IF OBJECT_ID('dbo.PricelistRetention') IS NOT NULL
    ALTER TABLE dbo.PricelistRetention SET (SYSTEM_VERSIONING = OFF);
DROP TABLE IF EXISTS dbo.PricelistRetention;
DROP TABLE IF EXISTS dbo.PricelistRetentionHistory;
-- Existing table with versioning inside the same table, common pattern
CREATE TABLE dbo.PricelistRetention
(
    ProductId INT NOT NULL,
    ListPrice MONEY NOT NULL,
    ValidFrom DATETIME NOT NULL
        CONSTRAINT DF_PricelistRetention_ValidFrom
            DEFAULT CURRENT_TIMESTAMP,
    ValidTo DATETIME,
    CONSTRAINT PK_PricelistRetention
        PRIMARY KEY (
                        ProductId,
                        ValidFrom
                    )
);

INSERT dbo.PricelistRetention
(
    ProductId,
    ListPrice
)
VALUES
(1, 10),
(2, 20),
(3, 30);
GO

UPDATE dbo.PricelistRetention
SET ValidFrom = DATEADD(DAY, -3, ValidFrom);

-- Change a price
DECLARE @dt DATETIME;
SET @dt = DATEADD(DAY, -3, CURRENT_TIMESTAMP);
-- Update current price row to invalidate it
UPDATE dbo.PricelistRetention
SET ValidTo = @dt
WHERE ProductId = 1
      AND ValidTo IS NULL;
-- Insert a new valid row
INSERT dbo.PricelistRetention
(
    ProductId,
    ListPrice,
    ValidFrom
)
VALUES
(1, 11, @dt);


-- Transform this table into one that works with system-versioning
ALTER TABLE dbo.PricelistRetention DROP CONSTRAINT PK_PricelistRetention;
ALTER TABLE dbo.PricelistRetention
DROP CONSTRAINT DF_PricelistRetention_ValidFrom;
ALTER TABLE dbo.PricelistRetention ALTER COLUMN ValidFrom DATETIME2(7);
ALTER TABLE dbo.PricelistRetention ALTER COLUMN ValidTo DATETIME2(7);

-- Fix values to align with system-versioning
UPDATE dbo.PricelistRetention
SET ValidTo = '9999-12-31 23:59:59.99999999'
WHERE ValidTo IS NULL;

-- Fix NOT NULL properties
ALTER TABLE dbo.PricelistRetention
ALTER COLUMN ValidFrom DATETIME2 NOT NULL;
ALTER TABLE dbo.PricelistRetention
ALTER COLUMN ValidTo DATETIME2 NOT NULL;

-- Create history table
CREATE TABLE dbo.PricelistRetentionHistory
(
    ProductID INT NOT NULL,
    ListPrice MONEY NOT NULL,
    ValidFrom DATETIME2(7) NOT NULL,
    ValidTo DATETIME2(7) NOT NULL
);


-- Move rows to history table
INSERT dbo.PricelistRetentionHistory
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
FROM dbo.PricelistRetention
WHERE ValidTo < '9999-12-31 23:59:59.9999999';

DELETE dbo.PricelistRetention
WHERE ValidTo < '9999-12-31 23:59:59.9999999';



-- Update times, they should be UTC-time
UPDATE dbo.PricelistRetention
SET ValidFrom = DATEADD(HOUR, -1, ValidFrom);

-- History table too.
UPDATE dbo.PricelistRetentionHistory
SET ValidFrom = DATEADD(HOUR, -1, ValidFrom),
    ValidTo = DATEADD(HOUR, -1, ValidTo);
GO

-- Now we can activate system versioning
ALTER TABLE dbo.PricelistRetention
ADD PERIOD FOR SYSTEM_TIME(ValidFrom, ValidTo);
ALTER TABLE dbo.PricelistRetention
ADD CONSTRAINT PK_PricelistRetention
    PRIMARY KEY (ProductId);
CREATE CLUSTERED INDEX ixc_PricelistRetentionHistory
ON dbo.PricelistRetentionHistory (
                                     ValidTo,
                                     ValidFrom
                                 );
ALTER TABLE dbo.PricelistRetention SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.PricelistRetentionHistory, HISTORY_RETENTION_PERIOD=1 DAYS));
GO

-- Run to here from the start

SELECT *
FROM dbo.PricelistRetentionHistory AS PRH;

-- Cleanup old history records
DECLARE @rowcount INT;
EXEC sys.sp_cleanup_temporal_history @schema_name = 'dbo',               -- sysname
                                     @table_name = 'PricelistRetention', -- sysname
                                     @rowcount = @rowcount OUTPUT;       -- int
SELECT @rowcount;
GO
SELECT *
FROM dbo.PricelistRetentionHistory AS PRH;


