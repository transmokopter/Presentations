USE SqlServerWorstPractices;
GO
SET NOCOUNT ON;
--Let's figure out the average rate for each currency.
--The "logic should be in the backend not the database" way

CREATE TABLE #t
(
    CurrencyCode CHAR(3),
    SumOfRates MONEY,
    RateCount INT
);

DECLARE cur CURSOR LOCAL FOR SELECT * FROM dbo.CurrencyRate AS CR;
DECLARE @Currencycode CHAR(3),
        @CurrencyRate MONEY,
        @CurrencyDate DATE;
OPEN cur;
FETCH NEXT FROM cur
INTO @Currencycode,
     @CurrencyDate,
     @CurrencyRate;
BEGIN TRAN;
WHILE @@FETCH_STATUS = 0
BEGIN
    MERGE #t AS t
    USING
    (SELECT @CurrencyRate AS rate, @Currencycode AS code) AS s
    ON t.CurrencyCode = s.code
    WHEN MATCHED THEN
        UPDATE SET t.SumOfRates = @CurrencyRate + t.SumOfRates,
                   t.RateCount = t.RateCount + 1
    WHEN NOT MATCHED THEN
        INSERT
        (
            CurrencyCode,
            SumOfRates,
            RateCount
        )
        VALUES
        (s.code, s.rate, 1);
    FETCH NEXT FROM cur
    INTO @Currencycode,
         @CurrencyDate,
         @CurrencyRate;
END;
COMMIT;
CLOSE cur;
DEALLOCATE cur;
SELECT CurrencyCode,
       SumOfRates / RateCount
FROM #t AS T;
GO
DROP TABLE #t;









-- _some_ logic in the database is OK
SELECT CurrencyCode,
       AVG(CR.Rate)
FROM dbo.CurrencyRate AS CR
GROUP BY CR.CurrencyCode;

GO



--------------------------------------------------------------------
-- MAGNUS!!!!! REMEMBER TO UNCHECK EXECUTION PLANS!!!!            --
--------------------------------------------------------------------



-- Ok, this was an obvious one. How about we generate a date-dimension?
DROP TABLE IF EXISTS dbo.dimDateRBAR;
DROP TABLE IF EXISTS dbo.dimDateRBARTran;
DROP TABLE IF EXISTS dbo.dimDate;
GO
SET NOCOUNT ON;
CREATE TABLE dbo.dimDateRBAR
(
    thedate DATE,
    WeekdayNumber TINYINT,
    WeekdayName VARCHAR(10),
    WeekNumber TINYINT,
    YearNumber SMALLINT,
    QuarterNumber TINYINT,
    MonthNumber TINYINT,
    MonthName VARCHAR(10)
);
DECLARE @startDate DATE = '2000-01-01';
DECLARE @endDate DATE = '2999-12-31';
DECLARE @executionBeginTime DATETIME2 = SYSDATETIME();

WHILE @startDate <= @endDate
BEGIN
    INSERT dbo.dimDateRBAR
    (
        thedate,
        WeekdayNumber,
        WeekdayName,
        WeekNumber,
        YearNumber,
        QuarterNumber,
        MonthNumber,
        MonthName
    )
    VALUES
    (@startDate, DATEPART(WEEKDAY, @startDate), DATENAME(WEEKDAY, @startDate), DATEPART(WEEK, @startDate),
     DATEPART(YEAR, @startDate), DATEPART(QUARTER, @startDate), DATEPART(MONTH, @startDate),
     DATENAME(MONTH, @startDate));
    SET @startDate = DATEADD(DAY, 1, @startDate);
END;

DECLARE @executionEndTime DATETIME2 = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @executionBeginTime, @executionEndTime);

CREATE CLUSTERED COLUMNSTORE INDEX ix_ccsi_dimDateRBAR ON dbo.dimDateRBAR;
-- Run this in another query window
SELECT COUNT(*)
FROM dbo.dimDateRBAR;
SELECT DATEDIFF(DAY, '2000-01-01', '2999-12-31');


-- But if we're going to use RBAR methods, let's at least make it as quick as can be. Use explicit transaction.

--------------------------------------------------------------------
-- MAGNUS!!!!! REMEMBER TO UNCHECK EXECUTION PLANS!!!!            --
--------------------------------------------------------------------

SET NOCOUNT ON;
GO
DROP TABLE IF EXISTS dbo.dimDateRBARTran;
GO
CREATE TABLE dbo.dimDateRBARTran
(
    thedate DATE,
    WeekdayNumber TINYINT,
    WeekdayName VARCHAR(10),
    WeekNumber TINYINT,
    YearNumber SMALLINT,
    QuarterNumber TINYINT,
    MonthNumber TINYINT,
    MonthName VARCHAR(10)
);
DECLARE @startDate DATE = '2000-01-01';
DECLARE @endDate DATE = '2999-12-31';
DECLARE @executionBeginTime DATETIME2 = SYSDATETIME();
BEGIN TRAN;
WHILE @startDate <= @endDate
BEGIN
    INSERT dbo.dimDateRBARTran
    (
        thedate,
        WeekdayNumber,
        WeekdayName,
        WeekNumber,
        YearNumber,
        QuarterNumber,
        MonthNumber,
        MonthName
    )
    VALUES
    (@startDate, DATEPART(WEEKDAY, @startDate), DATENAME(WEEKDAY, @startDate), DATEPART(WEEK, @startDate),
     DATEPART(YEAR, @startDate), DATEPART(QUARTER, @startDate), DATEPART(MONTH, @startDate),
     DATENAME(MONTH, @startDate));
    SET @startDate = DATEADD(DAY, 1, @startDate);
END;
COMMIT;
DECLARE @executionEndTime DATETIME2 = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @executionBeginTime, @executionEndTime);

CREATE CLUSTERED COLUMNSTORE INDEX ix_ccsi_dimDateRBARTran
ON dbo.dimDateRBARTran;
GO


-- How to make it fast, and without the need for an explicit transaction?

CREATE TABLE dbo.dimDate
(
    thedate DATE,
    WeekdayNumber TINYINT,
    WeekdayName VARCHAR(10),
    WeekNumber TINYINT,
    YearNumber SMALLINT,
    QuarterNumber TINYINT,
    MonthNumber TINYINT,
    MonthName VARCHAR(10)
);
DECLARE @startDate DATE = '2000-01-01';
DECLARE @endDate DATE = '2999-12-31';
DECLARE @executionBeginTime DATETIME2 = SYSDATETIME();
WITH cte
AS (SELECT DATEADD(DAY, value, @startDate) AS thedate
    FROM GENERATE_SERIES(0, DATEDIFF(DAY, @startDate, @endDate), 1))
INSERT dbo.dimDate
(
    thedate,
    WeekdayNumber,
    WeekdayName,
    WeekNumber,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName
)
SELECT thedate,
       DATEPART(WEEKDAY, thedate),
       DATENAME(WEEKDAY, thedate),
       DATEPART(WEEK, thedate),
       DATEPART(YEAR, thedate),
       DATEPART(QUARTER, thedate),
       DATEPART(MONTH, thedate),
       DATENAME(MONTH, thedate)
FROM cte;
DECLARE @executionEndTime DATETIME2 = SYSDATETIME();
SELECT DATEDIFF(MILLISECOND, @executionBeginTime, @executionEndTime);

CREATE CLUSTERED COLUMNSTORE INDEX ix_ccsi_dimDate ON dbo.dimDate;


GO

--Alternative to GENERATE_SERIES:
DECLARE @startDate DATE = '2000-01-01';
DECLARE @endDate DATE = '2999-12-31';

WITH ten
AS (SELECT 1 AS n
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1
    UNION ALL
    SELECT 1),
     million
AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM ten
        CROSS JOIN ten t2
        CROSS JOIN ten t3
        CROSS JOIN ten t4
        CROSS JOIN ten t5
        CROSS JOIN ten t6)
SELECT TOP (DATEDIFF(DAY, @startDate, @endDate))
       DATEADD(DAY, rn - 1, @startDate)
FROM million
ORDER BY rn;

GO