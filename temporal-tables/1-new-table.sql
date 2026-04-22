USE TemporalDb;
GO


IF OBJECT_ID('dbo.Pricelist') IS NOT NULL
BEGIN
    BEGIN TRY
        ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING = OFF);
    END TRY
    BEGIN CATCH
        PRINT 'system versioning not enabled for this table, no action here';
    END CATCH;
    DROP TABLE dbo.Pricelist;
    DROP TABLE IF EXISTS dbo.PricelistHistory;
END;
GO
-- New table. ProductId and ListPrice. 

CREATE TABLE dbo.Pricelist
(
    ProductId INT NOT NULL
        CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
    ListPrice MONEY NOT NULL
);




-- Not happy, we need history of prices
DROP TABLE IF EXISTS dbo.Pricelist;
GO



CREATE TABLE dbo.Pricelist
(
    ProductId INT NOT NULL
        CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
    ListPrice MONEY NOT NULL,
    RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME(RowStart, RowEnd)
)
WITH (
    SYSTEM_VERSIONING = ON (
        HISTORY_TABLE = dbo.PricelistHistory, 
        HISTORY_RETENTION_PERIOD = 6 DAYS));

GO


-- Let's add some data
INSERT dbo.Pricelist
(
    ProductId,
    ListPrice
)
VALUES
(1, 10),
(2, 20),
(3, 30);

-- Check table
SELECT *
FROM dbo.Pricelist;

-- Prices are wrong, let's fix that
UPDATE dbo.Pricelist
SET ListPrice = 11
WHERE ProductId = 1;

-- Object explorer.
-- Look into tables, structure in OE
-- Look at indexes


-- Check table again
SELECT *
FROM dbo.Pricelist;

SELECT *
FROM dbo.PricelistHistory;
