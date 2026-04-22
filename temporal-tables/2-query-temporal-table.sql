USE TemporalDb;
GO
DECLARE @dt DATETIME2;
SELECT @dt = DATEADD(SECOND, -1, RowEnd)
FROM dbo.PricelistHistory;
-- Check prices at a certain time
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME AS OF @dt;
GO

DECLARE @dtStart DATETIME2;
DECLARE @dtEnd DATETIME2 = CURRENT_TIMESTAMP;
SELECT @dtStart = DATEADD(SECOND, -1, RowStart)
FROM dbo.PricelistHistory;
-- All occurances within a given time period 
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME BETWEEN @dtStart AND @dtEnd;
GO
DECLARE @dtStart DATETIME2;
DECLARE @dtEnd DATETIME2 = CURRENT_TIMESTAMP;
SELECT @dtStart = DATEADD(SECOND, -1, RowStart)
FROM dbo.PricelistHistory;
-- Changes in a certain period
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME CONTAINED IN(@dtStart, @dtEnd);
GO
DECLARE @dtStart DATETIME2;
DECLARE @dtEnd DATETIME2 = CURRENT_TIMESTAMP;
SELECT @dtStart = DATEADD(SECOND, -1, RowStart)
FROM dbo.PricelistHistory;
-- Check prices that were valid in a date range
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME FROM @dtStart TO @dtEnd;
-- Notice that price for ProductId = 1 was valid twice within this time range, first between 
-- time a and b, and then between time b and indefinitely
GO
DECLARE @dtStart DATETIME2;
DECLARE @dtEnd DATETIME2;
SELECT @dtStart = DATEADD(SECOND, -1, RowStart)
FROM dbo.PricelistHistory;
SELECT @dtEnd = DATEADD(SECOND, -1, RowEnd)
FROM dbo.PricelistHistory;
SELECT *
FROM dbo.Pricelist
    FOR SYSTEM_TIME FROM @dtStart TO @dtEnd;
-- Notice that the NEW price for ProductId = 1 was never valid in the above given time range
GO
-- Give me everything
SELECT *
FROM dbo.Pricelist FOR SYSTEM_TIME ALL;
