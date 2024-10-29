USE SqlServerWorstPractices;
GO
-- Get value in currency x from value in currency y for a specific date
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency
(
    @FromCurrency CHAR(3),
    @ToCurrency CHAR(3),
    @ConversionDate DATE,
    @FromAmount MONEY
)
RETURNS MONEY
AS
BEGIN
    RETURN
    (
        SELECT @FromAmount * FromCurrency.Rate / ToCurrency.Rate AS AmountInToCurrency
        FROM dbo.CurrencyRate AS FromCurrency
            INNER JOIN dbo.CurrencyRate AS ToCurrency
                ON FromCurrency.CurrencyDate = ToCurrency.CurrencyDate
                   AND FromCurrency.CurrencyCode = @FromCurrency
                   AND ToCurrency.CurrencyCode = @ToCurrency
                   AND FromCurrency.CurrencyDate = @ConversionDate
    );
END;
GO
SET STATISTICS TIME, IO ON;
SELECT SUM(dbo.GetAmountInToCurrency(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue))
FROM dbo.SalesOrder AS SO
WHERE SO.OrderCurrency = 'SEK';
GO
SELECT SUM(dbo.GetAmountInToCurrency(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue))
FROM dbo.SalesOrder AS SO
WHERE SO.OrderCurrency = 'SEK'
      AND dbo.GetAmountInToCurrency(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue) > 1;
SET STATISTICS IO, TIME OFF;



GO
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency
(
    @FromCurrency CHAR(3),
    @ToCurrency CHAR(3),
    @ConversionDate DATE,
    @FromAmount MONEY
)
RETURNS MONEY
AS
BEGIN
    RETURN
    (
        SELECT @FromAmount * FromCurrency.Rate / ToCurrency.Rate AS AmountInToCurrency
        FROM
        (
            SELECT TOP (1)
                   Rate
            FROM dbo.CurrencyRate cr
            WHERE cr.CurrencyCode = @FromCurrency
                  AND cr.CurrencyDate <= @ConversionDate
            ORDER BY cr.CurrencyDate DESC
        ) AS FromCurrency
            CROSS JOIN
            (
                SELECT TOP (1)
                       Rate
                FROM dbo.CurrencyRate cr
                WHERE cr.CurrencyCode = @ToCurrency
                      AND cr.CurrencyDate <= @ConversionDate
                ORDER BY cr.CurrencyDate DESC
            ) AS ToCurrency
    );
END;
GO

SET STATISTICS TIME, IO ON;
SELECT SUM(dbo.GetAmountInToCurrency('SEK', 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue))
FROM dbo.SalesOrder AS SO
WHERE SO.OrderCurrency = 'SEK';
GO
SELECT SUM(dbo.GetAmountInToCurrency('SEK', 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue))
FROM dbo.SalesOrder AS SO
WHERE SO.OrderCurrency = 'SEK'
      AND dbo.GetAmountInToCurrency('SEK', 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue) > 1;
SET STATISTICS IO, TIME OFF;
GO
--How to do it better?
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency_TVF
(
    @FromCurrency CHAR(3),
    @ToCurrency CHAR(3),
    @ConversionDate DATE,
    @FromAmount MONEY
)
RETURNS TABLE
AS
RETURN
(
    SELECT CAST(@FromAmount * FromCurrency.Rate / ToCurrency.Rate AS MONEY) AS AmountInToCurrency
    FROM
    (
        SELECT TOP (1)
               Rate
        FROM dbo.CurrencyRate cr
        WHERE cr.CurrencyCode = @FromCurrency
              AND cr.CurrencyDate <= @ConversionDate
        ORDER BY cr.CurrencyDate DESC
    ) AS FromCurrency
        CROSS JOIN
        (
            SELECT TOP (1)
                   Rate
            FROM dbo.CurrencyRate cr
            WHERE cr.CurrencyCode = @ToCurrency
                  AND cr.CurrencyDate <= @ConversionDate
            ORDER BY cr.CurrencyDate DESC
        ) AS ToCurrency
);
GO
SET STATISTICS IO, TIME ON;
SELECT SUM(GAITCT.AmountInToCurrency)
FROM dbo.SalesOrder AS SO
    CROSS APPLY dbo.GetAmountInToCurrency_TVF(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue) AS GAITCT
WHERE SO.OrderCurrency = 'SEK'
      AND GAITCT.AmountInToCurrency > 1;
SET STATISTICS IO, TIME OFF;
GO
-- Or turn on UDF inlining

ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;
GO
SET STATISTICS IO, TIME ON;
SELECT SUM(dbo.GetAmountInToCurrency(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue))
FROM dbo.SalesOrder AS SO
WHERE SO.OrderCurrency = 'SEK'
      AND dbo.GetAmountInToCurrency(SO.OrderCurrency, 'USD', CAST(SO.OrderDate AS DATE), SO.OrderValue) > 1;
SET STATISTICS IO, TIME OFF;

