USE TemporalDb;
GO
-- Existing table, make it temporal 
CREATE TABLE dbo.Pricelist
(
    ProductId INT NOT NULL
        CONSTRAINT PK_Pricelist PRIMARY KEY CLUSTERED,
    ListPrice MONEY
);
GO
-- Let's add some data again
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



-- Now make this table system-versioned
ALTER TABLE dbo.Pricelist
ADD RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, --NOT NULL! 
    RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,     --NOT NULL!
    PERIOD FOR SYSTEM_TIME(RowStart, RowEnd);
GO
-- No, NOT NULL doesn't work without a default
ALTER TABLE dbo.Pricelist
ADD RowStart DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL CONSTRAINT DF_Pricelist_RowStart
                                                              DEFAULT (CURRENT_TIMESTAMP),         -- Use any default you want. Perhaps 1900-01-01 is better? 
    RowEnd DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL CONSTRAINT DF_Pricelist_RowEnd
                                                          DEFAULT ('9999-12-31 23:59:59.9999999'), -- This must be exactly this value!
    PERIOD FOR SYSTEM_TIME(RowStart, RowEnd);

-- And now we can make the table system versioned
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=dbo.PricelistHistory));
GO
