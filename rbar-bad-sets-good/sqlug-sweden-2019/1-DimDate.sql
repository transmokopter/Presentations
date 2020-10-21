use rbar;
SET NOCOUNT ON;
truncate table DimDate;
GO
--RBAR
BEGIN TRAN 
DECLARE @numrows int=100000;
--DECLARE @numrows int=datediff(day,'1400-01-01',CURRENT_TIMESTAMP);
DECLARE @i int=0;
DECLARE @dt date;
DECLARE @measure datetime2(7)=SYSDATETIME();
WHILE @i<@numrows 
BEGIN
 SET @dt=CAST(DATEADD(day,-@i,cast(CURRENT_TIMESTAMP as date)) as date);
 INSERT DimDate (
  datekey,
  dt,
  weekday,
  WeekDayName_EN,
  MonthNumber,
  MonthName_EN,
  YearNumber)
 VALUES(
  YEAR(@dt)*10000+MONTH(@dt)*100+DAY(@dt),
  @dt,
  DATEPART(weekday,@dt),
  DATENAME(weekday,@dt),
  MONTH(@dt),
  DATENAME(month,@dt),
  YEAR(@dt)
 )
 SET @i+=1;
END
COMMIT

SELECT DATEDIFF(millisecond,@measure,SYSDATETIME());


GO
TRUNCATE TABLE dbo.DimDate;
--Sets
DECLARE @numrows int=100000;
--DECLARE @numrows int=datediff(day,'1400-01-01',CURRENT_TIMESTAMP);
DECLARE @measure datetime2(7)=SYSDATETIME();
WITH ten AS(
 SELECT i FROM (values(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(i)
),thousands AS(
 SELECT TOP(@numrows)
  ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) as n
  FROM ten t1
  CROSS JOIN ten t2
  CROSS JOIN ten t3
  CROSS JOIN ten t4
  CROSS JOIN ten t5
  CROSS JOIN ten t6
  ORDER BY n 
),
dates as (
 SELECT CAST(dateadd(day,-(n-1),cast(current_timestamp as date)) as date) as dt 
 from thousands WHERE n BETWEEN 1 AND @numrows 
)
INSERT dbo.DimDate(
 datekey,
 dt,
 weekday,
 WeekDayName_EN,
 MonthNumber,
 MonthName_EN,
 YearNumber)
SELECT
 YEAR(dt)* 10000 + MONTH(dt)*100 + DAY(dt),
 dt,
 DATEPART(weekday,dt),
 DATENAME(weekday,dt),
 MONTH(dt),
 DATENAME(month,dt),
 YEAR(dt)
FROM dates;
SELECT DATEDIFF(millisecond,@measure,SYSDATETIME());


