CREATE OR ALTER PROC dbo.GenerateLetterStrings
(
    @LetterCount TINYINT,
    @ResultTable NVARCHAR(128) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX)
        = N'
WITH alphabet AS (
    SELECT CHAR(ASCII(''A'')+ ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) -1) AS n 
    FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) t(n)
)SELECT 
    <<selectlist>> AS word
    <<intoclause>>
FROM alphabet AS t0
<<crossjoin>>
'   ;
    DECLARE @SelectList NVARCHAR(MAX) = N't0.n',
            @CrossJoin NVARCHAR(MAX) = N'';
    WITH eight
    AS (SELECT n
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
                (1)
        ) t (n) ),
         twofiftysix
    AS (SELECT TOP (@LetterCount - 1)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM eight
            CROSS JOIN eight e2
        ORDER BY 1)
    SELECT @CrossJoin = @CrossJoin + CONCAT('CROSS JOIN alphabet as t', n, '
        '),
           @SelectList = @SelectList + CONCAT('+t', n, '.n')
    FROM twofiftysix;
    SET @sql = REPLACE(@sql, N'<<selectlist>>', @SelectList);
    SET @sql = REPLACE(@sql, N'<<crossjoin>>', @CrossJoin);
    SET @sql = REPLACE(@sql, N'<<intoclause>>', COALESCE(N'INTO ' + @ResultTable, N''));
    EXEC sys.sp_executesql @sql;
END;
GO
DROP TABLE IF EXISTS dbo.PerformanceMeasures;
GO
CREATE TABLE dbo.PerformanceMeasures(Method VARCHAR(20), WordLength TINYINT, RowsCount INT, MilliSeconds int);
GO




DECLARE @WordLength TINYINT=2
WHILE @WordLength<=6
BEGIN 
	DROP TABLE IF EXISTS #t;
	CREATE TABLE #t(code CHAR(4));
	DECLARE @TimeStart DATETIME2(7)=CURRENT_TIMESTAMP;
	EXEC dbo.GenerateLetterStrings @LetterCount = @WordLength,  -- tinyint
								   @ResultTable = N'#t' -- nvarchar(128)

	INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
	SELECT 'TallyTable',@WordLength,POWER(26,@WordLength), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
	SET @WordLength += 1;
END

GO


DECLARE @WordLength TINYINT=2
WHILE @WordLength<=6
BEGIN 
	DECLARE @TimeStart DATETIME2(7)=CURRENT_TIMESTAMP;

	DROP TABLE IF EXISTS #t;
	WITH cte AS (
		SELECT CHAR(ASCII('A')+ROW_NUMBER() OVER(ORDER BY (SELECT NULL))-1) AS c
		FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1))t(n)

	), codes(code,width) AS (
		SELECT CAST(c AS VARCHAR(8)), CAST(1 AS INT) FROM cte 
		UNION ALL 
		SELECT CAST(c.code + a.c AS VARCHAR(8)),c.width + 1 FROM codes c 
		CROSS JOIN cte a
		WHERE c.width < @WordLength
	)SELECT code INTO #t FROM codes WHERE width=@WordLength ORDER BY code ASC ;
	INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
	SELECT 'rCTE',@WordLength,POWER(26,@WordLength), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
	SET @WordLength += 1;
END
GO


SET NOCOUNT ON 
DROP TABLE IF EXISTS #t;
GO
CREATE TABLE #t(c CHAR(2));
DECLARE @timestart DATETIME2=CURRENT_TIMESTAMP;
BEGIN TRAN 
DECLARE @i INT=0, @j INT=0, @k INT=0, @l INT = 0;
		WHILE @k < 26
		BEGIN 
			WHILE @l < 26
			BEGIN 
				INSERT INTO #t(c) 
					VALUES(CHAR(ASCII('A')+@k) + CHAR(ASCII('A')+@l));
					SET @l = @l+1;
			END
			SET @k = @k+1;
			SET @l=0;
		END 
COMMIT 
INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
SELECT 'Loop',2,POWER(26,2), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
GO


SET NOCOUNT ON 
DROP TABLE IF EXISTS #t;
GO
CREATE TABLE #t(c CHAR(3));
DECLARE @timestart DATETIME2=CURRENT_TIMESTAMP;
BEGIN TRAN 
DECLARE @i INT=0, @j INT=0, @k INT=0, @l INT = 0;
	WHILE @j< 26 
	BEGIN 
		WHILE @k < 26
		BEGIN 
			WHILE @l < 26
			BEGIN 
				INSERT INTO #t(c) 
					VALUES(CHAR(ASCII('A')+@j) + CHAR(ASCII('A')+@k) + CHAR(ASCII('A')+@l));
					SET @l = @l+1;
			END
			SET @k = @k+1;
			SET @l=0;
		END 
		SET @j = @j + 1;
		SET @k = 0;
	END 
COMMIT 
INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
SELECT 'Loop',3,POWER(26,3), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
GO


SET NOCOUNT ON 
DROP TABLE IF EXISTS #t;
GO
CREATE TABLE #t(c CHAR(4));
DECLARE @timestart DATETIME2=CURRENT_TIMESTAMP;
BEGIN TRAN 
DECLARE @i INT=0, @j INT=0, @k INT=0, @l INT = 0;
WHILE @i<26
BEGIN 
	WHILE @j< 26 
	BEGIN 
		WHILE @k < 26
		BEGIN 
			WHILE @l < 26
			BEGIN 
				INSERT INTO #t(c) 
					VALUES(CHAR(ASCII('A')+@i) + CHAR(ASCII('A')+@j) + CHAR(ASCII('A')+@k) + CHAR(ASCII('A')+@l));
					SET @l = @l+1;
			END
			SET @k = @k+1;
			SET @l=0;
		END 
		SET @j = @j + 1;
		SET @k = 0;
	END 
	SET @i = @i + 1;
	SET @j = 0;
END 
COMMIT 
INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
SELECT 'Loop',4,POWER(26,4), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
GO


SET NOCOUNT ON 
DROP TABLE IF EXISTS #t;
GO
CREATE TABLE #t(c CHAR(5));
DECLARE @timestart DATETIME2=CURRENT_TIMESTAMP;
BEGIN TRAN 
DECLARE @i INT=0, @j INT=0, @k INT=0, @l INT = 0, @h INT =0;
WHILE @h<26
BEGIN
	WHILE @i<26
	BEGIN 
		WHILE @j< 26 
		BEGIN 
			WHILE @k < 26
			BEGIN 
				WHILE @l < 26
				BEGIN 
					INSERT INTO #t(c) 
						VALUES(CHAR(ASCII('A')+@h) + CHAR(ASCII('A')+@i) + CHAR(ASCII('A')+@j) + CHAR(ASCII('A')+@k) + CHAR(ASCII('A')+@l));
						SET @l = @l+1;
				END
				SET @k = @k+1;
				SET @l=0;
			END 
			SET @j = @j + 1;
			SET @k = 0;
		END 
		SET @i = @i + 1;
		SET @j = 0;
	END 
	SET @h = @h + 1;
	SET @i = 0;
END
COMMIT 
INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
SELECT 'Loop',5,POWER(26,5), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
GO


SET NOCOUNT ON 
DROP TABLE IF EXISTS #t;
GO
CREATE TABLE #t(c CHAR(6));
DECLARE @timestart DATETIME2=CURRENT_TIMESTAMP;
BEGIN TRAN 
DECLARE @i INT=0, @j INT=0, @k INT=0, @l INT = 0, @h INT = 0, @g INT = 0;;
WHILE @g < 26
BEGIN
	WHILE @h<26
	BEGIN
		WHILE @i<26
		BEGIN 
			WHILE @j< 26 
			BEGIN 
				WHILE @k < 26
				BEGIN 
					WHILE @l < 26
					BEGIN 
						INSERT INTO #t(c) 
							VALUES(CHAR(ASCII('A')+@h) + CHAR(ASCII('A')+@i) + CHAR(ASCII('A')+@j) + CHAR(ASCII('A')+@k) + CHAR(ASCII('A')+@l));
							SET @l = @l+1;
					END
					SET @k = @k+1;
					SET @l=0;
				END 
				SET @j = @j + 1;
				SET @k = 0;
			END 
			SET @i = @i + 1;
			SET @j = 0;
		END 
		SET @h = @h + 1;
		SET @i = 0;
	END
		SET @g = @g + 1;
		SET @h = 0;
END
COMMIT 
INSERT dbo.PerformanceMeasures(Method,WordLength,RowsCount,MilliSeconds)
SELECT 'Loop',6,POWER(26,6), DATEDIFF(MILLISECOND, @TimeStart, CURRENT_TIMESTAMP)
GO
