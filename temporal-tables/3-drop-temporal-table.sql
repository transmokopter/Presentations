USE TemporalDb;
GO
-- Drop table, we want to start over
DROP TABLE dbo.Pricelist;
-- Can't drop a table that's system versioned


GO
ALTER TABLE dbo.Pricelist SET (SYSTEM_VERSIONING = OFF);
DROP TABLE dbo.Pricelist;
DROP TABLE dbo.PricelistHistory;

