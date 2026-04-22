USE TemporalDb;
GO
-- Let's checkout execution plan:
DECLARE @asOf DATETIME2 = DATEADD(MINUTE, -3, CURRENT_TIMESTAMP);
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME AS OF @asOf;
-- Predicate on history table - retention matters.
