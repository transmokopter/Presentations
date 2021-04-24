--First let's create some data
USE StatsDemo

CREATE TABLE dbo.Cars (
	CarID INT IDENTITY(1,1) CONSTRAINT PK_Cars PRIMARY KEY CLUSTERED,
	BrandName VARCHAR(15) NOT NULL,
	ModelName VARCHAR(15) NOT NULL,
	Color VARCHAR(10) NOT NULL
);

WITH CTE AS (
	SELECT n FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(n)
), CTE2 AS ( SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM CTE AS c CROSS JOIN CTE AS c2 CROSS JOIN CTE AS c3 CROSS JOIN CTE AS c4)
INSERT dbo.Cars(BrandName, ModelName, Color)
	SELECT 'Volvo', 'S40','Red' FROM CTE2 WHERE n % 5 = 0
	UNION ALL
	SELECT 'Volvo', 'V70','Blue' FROM CTE2 WHERE n % 2 = 0
	UNION ALL
	SELECT 'SAAB','93','Black' FROM CTE2 WHERE n % 19 = 0
	UNION ALL
	SELECT 'SAAB','93','Red' FROM CTE2 WHERE n % 37 = 0

--Now use SQL 2012
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 110

SELECT * FROM dbo.cars WHERE brandname='Volvo'
SELECT * FROM dbo.cars WHERE modelname='v70'
SELECT * FROM dbo.cars WHERE color='red'

EXEC sp_helpstats 'dbo.Cars'
--Replace these
DBCC SHOW_STATISTICS('dbo.cars',_WA_Sys_00000002_3A81B327) WITH HISTOGRAM
DBCC SHOW_STATISTICS('dbo.cars',_WA_Sys_00000003_3A81B327) WITH HISTOGRAM
DBCC SHOW_STATISTICS('dbo.cars',_WA_Sys_00000004_3A81B327) WITH HISTOGRAM
--How many Volvos do we have? Probably around 7000
--How many Red cars do we have? Probably around 2270
--How many V70 do we have? Probably around 5000
--So. How many SAAB V70 do we have?
--Or Volvo V70?
--Or Red Volvo V70?

--Look at estimates
SELECT COUNT(*) FROM dbo.Cars AS C WHERE C.BrandName='SAAB'
SELECT COUNT(*) FROM dbo.Cars AS C WHERE C.Color='Red'
SELECT COUNT(*) FROM dbo.Cars AS C WHERE C.ModelName='V70'

--Look at estimates
SELECT COUNT(*) FROM dbo.Cars AS C WHERE c.BrandName='SAAB' AND ModelName = 'V70'
--Wut? Where did SQL Server come up with that number?

SELECT COUNT(*) FROM dbo.Cars AS C WHERE c.BrandName='Volvo' AND ModelName = 'V70' OPTION(RECOMPILE)
--And this? It's higher, but where does it come from?

SELECT COUNT(*) FROM dbo.Cars AS C WHERE c.BrandName='Volvo' AND ModelName = 'V70' AND C.Color='Red'
--Once again, where does 1307,2 come from?


--Cardinality estimation with multiple predicates on same table
--Old CE
-- (<Estimate for first predicate> x <Estimate for second predicate> / <Rowcount>) x (Estimate for third predicate / <RowCount>)
-- Etc
--(7000 Volvo x 5000 V70 / 7796 rows) x 2270 Red cars / 7796 rows
SELECT (7000.0 * 5000 / 7796) * 2270 / 7796


--Now let's upgrade to SQL 2014 (or later, it's the same CE in this respect)
ALTER DATABASE StatsDemo SET COMPATIBILITY_LEVEL = 120

SELECT COUNT(*) FROM dbo.Cars AS C WHERE c.BrandName='Volvo' AND ModelName = 'V70' AND C.Color='Red'
--1769. That's another number. 

--New CE
--<Selectivity for most selective predicate> x 
--<Square Root of selectivity for second most selective predicate> x
--<Cubic root of selectivity for third most selective predicate> x 
--Rowcount
-- Etc
--(2270 Red / 7796 rows) x Square_root(5000 V70 / 7796 rows) x Cubic_root(7000 Volvo / 7796 rows) * 7796 rows
SELECT 
	(2270.0 / 7796) * 
	SQRT(5000.0 / 7796) *
	SQRT(SQRT(7000.0/7796)) *
	7796

--Actual number of rows = 0
SELECT COUNT(*) FROM dbo.Cars AS C WHERE c.BrandName='Volvo' AND ModelName = 'V70' AND C.Color='Red'



--Back to orders database...



--Addition AFTER Sql Saturday Oslo, just as comment, will create demos to "prove" this odd behaviour
--Now where did THAT estimate come from?
--It _seems_ like the logic is this:
--The lesser values of:
--Density*TotalRowcount and SQRT(TotalRowcount)
--Density*TotalRowcount is about 12500 rows
--
--SQRT(TotalRowcount) is about 1700 rows, so that value is chosen
