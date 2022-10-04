SELECT @@version

USE sql2022
SELECT * FROM dbo.instanceSpecs;

ALTER TABLE dbo.instanceSpecs 
ADD CONSTRAINT PK_instanceSpecs PRIMARY KEY CLUSTERED (instanceName) 
WITH (RESUMABLE=ON,ONLINE=ON,MAX_DURATION=30);
ALTER INDEX ALL ON dbo.instanceSpecs PAUSE;
ALTER INDEX ALL ON dbo.instanceSpecs RESUME WITH (MAXDOP = 2, MAX_DURATION = 240 MINUTES,
      WAIT_AT_LOW_PRIORITY (MAX_DURATION = 10, ABORT_AFTER_WAIT = BLOCKERS)) ;
	  


--Named Windows
SELECT 
	COUNT(*) OVER AllRowsWindows TotalCount,
	COUNT(*) OVER SameCPUCountWindow AS CountWithSameCPUs,
	*
FROM dbo.instanceSpecs
WINDOW SameCPUCountWindow AS 
	(PARTITION BY cpuCount ORDER BY (SELECT NULL) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
AllRowsWindows AS ();


--DISTINCT FROM
SELECT * FROM dbo.instanceSpecs WHERE cpuCount <> 4;
SELECT * FROM dbo.instanceSpecs WHERE cpuCount = 4;
--How about NULLS?
SELECT * FROM dbo.instanceSpecs WHERE cpuCount <>4 OR cpuCount IS NULL;
--Alternative
SELECT * FROM dbo.instanceSpecs WHERE NOT EXISTS(SELECT 4 INTERSECT SELECT cpuCount);
--SQL 2022
SELECT * FROM dbo.instanceSpecs WHERE cpuCount IS DISTINCT FROM 4;

--DATE_BUCKET
SELECT DATE_BUCKET(MONTH,3,CURRENT_TIMESTAMP);  --Base date = default date = 1900-01-01

SELECT DATE_BUCKET(MONTH,3,CURRENT_TIMESTAMP,CAST('2022-11-01' AS DATETIME));  --Base date = 2021-11-01

--GENERATE_SERIES
SELECT * 
FROM GENERATE_SERIES(1,100);
--With different step value than 1
SELECT * 
FROM GENERATE_SERIES(1,100,3) AS t;
--Now with dates
SELECT * FROM generate_series(CAST('2021-11-01' AS DATE),CAST('2025-12-31' AS DATE))
--Nope
SELECT DATEADD(DAY,t.value,CAST('2021-11-01' AS DATE))
FROM GENERATE_SERIES(0,1000) AS t;

WITH CTE AS (
SELECT DATEADD(DAY,t.value,CAST('2021-11-01' AS DATE)) AS reportingDate
FROM GENERATE_SERIES(0,1000) AS t
)
SELECT CTE.reportingDate,
	DATE_BUCKET(MONTH,3,CTE.reportingDate,CAST('2021-11-01' AS DATE))
FROM CTE;



--ISJSON
SELECT ISJSON('hi there!!');
SELECT ISJSON('{"hi":"there"}')
--JSON_PATH_EXISTS
DECLARE @jsonInfo NVARCHAR(MAX);
SET @jsonInfo=N'{"person":{"address":[{"town":"Enköping"},{"town":"Oslo"}]}}';
SELECT JSON_PATH_EXISTS(@jsonInfo,'$.info.addresses'); 
SELECT JSON_PATH_EXISTS(@jsonInfo,'$.person.address[1].town');

--JSON_OBJECT and JSON_ARRAY
SELECT 
	JSON_OBJECT(N'person':
		JSON_OBJECT('address':
			JSON_ARRAY(
				JSON_OBJECT('town':'Enköping'),
				JSON_OBJECT('town':'Oslo')
			)
		)
	);


--enable_ordinal in STRING_SPLIT
SELECT * FROM 
	STRING_SPLIT(N'1,2,3,4,5,6',N',');
--with ordinal
SELECT * FROM 
	STRING_SPLIT(N'1,2,3,4,5,6',N',',1);
--without ordinal - default behaviour
SELECT * FROM 
	STRING_SPLIT(N'1,2,3,4,5,6',N',',0);

--GREATEST, LEAST
SELECT 
	*,
	LEAST(cpuCount/2,8) AS TempDBFiles
FROM
dbo.instanceSpecs;

--DATETRUNC
SELECT DATETRUNC(year,CURRENT_TIMESTAMP);

--We always wanted FOMONTH, right?
SELECT DATETRUNC(month,CURRENT_TIMESTAMP) AS FOMONTH;

--LTRIM, RTRIM, TRIM
SELECT TRIM(LEADING 'abc' FROM 'abc123abc');
SELECT TRIM(TRAILING 'abc' FROM 'abc123abc');
SELECT TRIM(BOTH 'abc' FROM 'abc123abc');

--Bitwise!
SELECT GET_BIT(8,3);
SELECT BIT_COUNT(7);
SELECT SET_BIT(8,0);
SELECT LEFT_SHIFT(8,1);
SELECT RIGHT_SHIFT(8,1);
