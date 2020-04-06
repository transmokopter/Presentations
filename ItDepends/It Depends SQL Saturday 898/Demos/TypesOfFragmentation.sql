USE ssd;

SELECT * INTO dbo.WideNew FROM dbo.Wide;
CREATE CLUSTERED INDEX cl_WideNew ON WideNew(c1);

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('Wide'),NULL,NULL,'limited')
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('WideNew'),NULL,NULL,'limited')
EXEC sp_configure 'cursor threshold', 1000000
RECONFIGURE

SET STATISTICS IO,Time ON;

CHECKPOINT;
DBCC DROPCLEANBUFFERS;

SELECT COUNT_BIG(c1) FROM WideNew;


WITH CTE AS (
	SELECT ROW_NUMBER() OVER(ORDER BY c1) AS rn,* FROM WideNew 
)DELETE CTE WHERE rn % 2 =0;

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
SELECT COUNT_BIG(c1) FROM WideNew;

--Slow, more logging but online
ALTER INDEX cl_WideNew ON WIdeNew REORGANIZE;

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
SELECT COUNT_BIG(c1) FROM WideNew;


EXEC sp_configure 'cursor threshold',-1
RECONFIGURE;

DROP TABLE dbo.WideNew;
