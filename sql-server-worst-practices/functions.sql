USE SqlServerWorstPractices
GO
-- Get value in currency x from value in currency y for a specific date
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency(
	@FromCurrency CHAR(3),
	@ToCurrency CHAR(3),
	@ConversionDate DATE,
	@FromAmount MONEY
)
RETURNS MONEY 
AS
BEGIN
	RETURN 
	(SELECT 
		@FromAmount * FromCurrency.Rate / ToCurrency.Rate AS AmountInToCurrency
	FROM dbo.CurrencyRate AS FromCurrency
	INNER JOIN dbo.CurrencyRate AS ToCurrency ON 
		FromCurrency.CurrencyDate=ToCurrency.CurrencyDate 
		AND FromCurrency.CurrencyCode=@FromCurrency 
		AND ToCurrency.CurrencyCode = @ToCurrency
		AND FromCurrency.CurrencyDate = @ConversionDate
	)
END
GO
SET STATISTICS TIME,IO ON;
SELECT SUM(dbo.GetAmountInToCurrency('SEK','USD',CAST(so.OrderDate AS DATE),so.OrderValue))
FROM dbo.SalesOrder AS SO 
WHERE SO.OrderCurrency='SEK' 
OPTION(RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 2363);
GO
SELECT SUM(dbo.GetAmountInToCurrency('SEK','USD',CAST(so.OrderDate AS DATE),so.OrderValue))
FROM dbo.SalesOrder AS SO 
WHERE SO.OrderCurrency='SEK' 
	AND dbo.GetAmountInToCurrency('SEK','USD',CAST(so.OrderDate AS DATE),so.OrderValue)>1 
	OPTION(RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 2363);
;
SET STATISTICS IO,TIME OFF;



GO
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency(
	@FromCurrency CHAR(3),
	@ToCurrency CHAR(3),
	@ConversionDate DATE,
	@FromAmount MONEY
)
RETURNS MONEY 
AS
BEGIN
	RETURN 
	(SELECT 
		@FromAmount * FromCurrency.Rate / ToCurrency.Rate AS AmountInToCurrency
	FROM 
	(SELECT TOP(1) Rate FROM dbo.CurrencyRate cr WHERE cr.CurrencyCode=@FromCurrency AND cr.CurrencyDate<=@ConversionDate ORDER BY cr.CurrencyDate DESC) AS FromCurrency
	CROSS JOIN 
	(SELECT TOP(1) Rate FROM dbo.CurrencyRate cr WHERE cr.CurrencyCode=@ToCurrency AND cr.CurrencyDate<=@ConversionDate ORDER BY cr.CurrencyDate DESC) AS ToCurrency
	)
END
GO

SET STATISTICS TIME,IO ON;
SELECT SUM(dbo.GetAmountInToCurrency('SEK','USD',DATEADD(DAY,-1*value,CAST('2024-04-18' AS DATE)),'100'))
FROM generate_series(0,10000,1);
GO
SELECT SUM(dbo.GetAmountInToCurrency('SEK','USD',DATEADD(DAY,-1*value,CAST('2024-04-18' AS DATE)),'100'))
FROM generate_series(0,10000,1)
WHERE dbo.GetAmountInToCurrency('SEK','USD',DATEADD(DAY,-1*value,CAST('2024-04-18' AS DATE)),'100')>10
;

--How to do it better?
CREATE OR ALTER FUNCTION dbo.GetAmountInToCurrency_TVF(
	@FromCurrency CHAR(3),
	@ToCurrency CHAR(3),
	@ConversionDate DATE,
	@FromAmount MONEY
)
RETURNS TABLE
AS
	RETURN 
	(SELECT 
		@FromAmount * FromCurrency.Rate / ToCurrency.Rate AS AmountInToCurrency
	FROM 
	(SELECT TOP(1) Rate FROM dbo.CurrencyRate cr WHERE cr.CurrencyCode=@FromCurrency AND cr.CurrencyDate<=@ConversionDate ORDER BY cr.CurrencyDate DESC) AS FromCurrency
	CROSS JOIN 
	(SELECT TOP(1) Rate FROM dbo.CurrencyRate cr WHERE cr.CurrencyCode=@ToCurrency AND cr.CurrencyDate<=@ConversionDate ORDER BY cr.CurrencyDate DESC) AS ToCurrency
	);
GO
SET STATISTICS IO,TIME ON;
SELECT SUM(GAITCT.AmountInToCurrency)
FROM generate_series(0,100000,1) AS GS
CROSS APPLY dbo.GetAmountInToCurrency_TVF('SEK','USD',DATEADD(DAY,-1*GS.value,CAST('2024-04-18' AS DATE)),'100') AS GAITCT
WHERE GAITCT.AmountInToCurrency>10;
SET STATISTICS IO,TIME OFF;
GO
-- Or turn on UDF inlining

