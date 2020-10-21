USE rbar;

--RBAR
GO
CREATE OR ALTER FUNCTION dbo.splitstring_RBAR
(
  @s VARCHAR(8000),
  @separator CHAR(1) = ','
)
RETURNS @t TABLE
(
  val VARCHAR(100)
)
AS
BEGIN
  DECLARE @val VARCHAR(100);
  DECLARE @pos INT;

  WHILE CHARINDEX(@separator, @s) > 0
  BEGIN
    SET @pos = CHARINDEX(@separator, @s);

    INSERT @t
      (
        val
      )
    SELECT SUBSTRING(@s, 1, @pos - 1);

    SET @s = SUBSTRING(@s, @pos + 1, LEN(@s) - @pos);
  END;

  INSERT @t
    (
      val
    )
  SELECT @s;

  RETURN;
END;

GO
DECLARE @s VARCHAR(MAX) = '1,2,3,4,5,6,7,8,9,10';
SELECT *
FROM dbo.splitstring_RBAR(@s, DEFAULT);
GO
--Sets
CREATE OR ALTER FUNCTION dbo.splitstring_SETS
(
  @s VARCHAR(8000),
  @separator CHAR(1) = ','
)
RETURNS TABLE
AS
RETURN
(
  WITH ten
  AS (SELECT t.i
      FROM
      (
        VALUES
          (1),
          (1),
          (1),
          (1),
          (1),
          (1),
          (1),
          (1),
          (1),
          (1)
      ) AS t (i) ),
       thousands
  AS (SELECT TOP (LEN(@s))
             ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
      FROM ten AS t1
           CROSS JOIN ten AS t2
           CROSS JOIN ten AS t3
           CROSS JOIN ten AS t4
           CROSS JOIN ten AS t5
           CROSS JOIN ten AS t6
      ORDER BY n),
       bounds
  AS (SELECT 0 AS n
      UNION ALL
      SELECT thousands.n
      FROM thousands
      WHERE SUBSTRING(@s, thousands.n, 1) = @separator
      UNION ALL
      SELECT LEN(@s) + 1 AS n),
       vals
  AS (SELECT SUBSTRING(@s, bounds.n + 1, LEAD(bounds.n) OVER (ORDER BY bounds.n) - bounds.n - 1) AS val
      FROM bounds)
  SELECT vals.val
  FROM vals
  WHERE vals.val IS NOT NULL
);
GO
DECLARE @s VARCHAR(MAX) = '1,2,3,4,5,6,7,8,9,10';
SELECT *
FROM dbo.splitstring_SETS(@s, DEFAULT);
GO


DROP TABLE #t;
--RBAR on speed
CREATE TABLE #t
(
  s VARCHAR(MAX)
);
go
INSERT #t
  (
    s
  )
VALUES
('1,2,3,4,5,6,7,8,9'),
('a,b,c,d'),
('e,f,g,h'),
('i,j,k,l'),
('m,n,o,p'),
('q,r,s,t'),
('u,v,w,x'),
('y,z');
INSERT #t
  (
    s
  )
SELECT REVERSE(s)
FROM #t;

WITH cte
AS (SELECT t.val 
    FROM #t
         CROSS APPLY dbo.splitstring_SETS(s, ',')t ) 
INSERT #t
  (
    s
  )
SELECT CONCAT(
	val,',',
	LEAD(val,2) OVER(ORDER BY (SELECT NEWID())),',',
	LEAD(val,3) OVER(ORDER BY (SELECT NEWID())),',',
	LEAD(val,5) OVER(ORDER BY (SELECT NEWID())),',',
	LEAD(val,7) OVER(ORDER BY (SELECT NEWID())),','
	)
FROM cte ;
GO 5

DECLARE @v VARCHAR(8000);
DECLARE @measure datetime2(7)=SYSDATETIME();
SELECT @v=val FROM #t CROSS APPLY dbo.splitstring_RBAR(s,',')
SELECT DATEDIFF(millisecond,@measure,SYSDATETIME());
GO
DECLARE @v VARCHAR(8000);
DECLARE @measure datetime2(7)=SYSDATETIME();
SELECT @v=value FROM #t CROSS APPLY string_split(s,',')
SELECT DATEDIFF(millisecond,@measure,SYSDATETIME());

