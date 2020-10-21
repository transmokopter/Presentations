EXEC sp_configure 'show advanced options',1
RECONFIGURE WITH OVERRIDE
IF 1=1 
BEGIN 
	USE master 
	DROP DATABASE IF EXISTS ssd;
	CREATE DATABASE [ssd]
	 CONTAINMENT = NONE
	 ON  PRIMARY 
	( NAME = N'ssd', FILENAME = N'c:\sqldata\MSSQL15.MSSQLSERVER\MSSQL\Data\ssd.mdf' , SIZE = 1024000KB , FILEGROWTH = 512000KB )
	 LOG ON 
	( NAME = N'ssd_log', FILENAME = N'c:\sqldata\MSSQL15.MSSQLSERVER\MSSQL\Data\ssd_log.ldf' , SIZE = 512000KB , FILEGROWTH = 512000KB )
END 

--Stolen with pride from Tibor Karaszi
--www.karaszi.com


--Cleanup any extended event session runs
SET NOCOUNT ON
begin try
ALTER EVENT SESSION ssd_frag_test ON SERVER STATE = STOP
end try
begin catch
print 'already stopped.'
end catch

WAITFOR DELAY '00:00:02'
--Delete XE file, using xp_cmdshell (bad, I know)
EXEC sp_configure 'xp_cmdshell', 1 RECONFIGURE WITH OVERRIDE
EXEC xp_cmdshell 'DEL c:\sqldata\MSSQL15.MSSQLSERVER\MSSQL\Data\ssd_frag_test*.xel', no_output
EXEC sp_configure 'xp_cmdshell', 0 RECONFIGURE WITH OVERRIDE
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'ssd_frag_test')
DROP EVENT SESSION ssd_frag_test ON SERVER

--Create new event session
CREATE EVENT SESSION ssd_frag_test ON SERVER
ADD EVENT sqlserver.sp_statement_completed()
ADD TARGET package0.event_file(SET filename=N'c:\sqldata\MSSQL15.MSSQLSERVER\MSSQL\Data\ssd_frag_test')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=2 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO
ALTER EVENT SESSION ssd_frag_test ON SERVER STATE = START


--Disable IAM order scan, so we know that SQL Server will follow the linked list
--See https://sqlperformance.com/2015/01/t-sql-queries/allocation-order-scans
EXEC sp_configure 'cursor threshold', 1000000
RECONFIGURE

--Setup section
--Pregrown data files
USE SSD
DROP TABLE IF EXISTS narrow_index
--Create the table for the narrow index
SELECT TOP(1000*10000) ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) AS c1, CAST('Hello' AS char(8)) AS c2
INTO narrow_index
FROM sys.columns AS a, sys.columns AS b, sys.columns AS c
CREATE CLUSTERED INDEX x ON narrow_index(c1)
GO

--Create table for a slightly wider index. Tibor used Posts table in Stackoverflow
DROP TABLE IF EXISTS Wide;
CREATE TABLE Wide (c1 UNIQUEIDENTIFIER DEFAULT NEWID(),
c2 UNIQUEIDENTIFIER DEFAULT NEWID(),
c3 UNIQUEIDENTIFIER DEFAULT NEWID(),
c4 UNIQUEIDENTIFIER DEFAULT NEWID(),
c5 UNIQUEIDENTIFIER DEFAULT NEWID(),
c6 UNIQUEIDENTIFIER DEFAULT NEWID(),
c7 bigint);
INSERT Wide(c7) 
--Slow 'puter, using lesser rows
SELECT TOP(1000*2000) 
ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
FROM sys.columns AS a, sys.columns AS b, sys.columns AS c
--Perfectly non-fragmented index now
CREATE CLUSTERED INDEX cl_wide ON Wide(c1);

GO
CREATE OR ALTER PROC run_the_sql
@fragmented varchar(20)
AS
DECLARE
@sql varchar(1000)
--Empty cache
CHECKPOINT
DBCC DROPCLEANBUFFERS
--Cold cache

SET @sql = 'DECLARE @a int SET @a = (SELECT COUNT_BIG(c1) AS [nc_ix_scan ' + @fragmented + '] FROM narrow_index)'
EXEC (@sql)
SET @sql='DECLARE @a int SET @a=(SELECT COUNT_BIG(c1) AS [cl_ix_scan ' + @fragmented + '] FROM Wide)'
EXEC (@sql)
--Warm cache
SET @sql = 'DECLARE @a int SET @a = (SELECT COUNT_BIG(c1) AS [nc_ix_scan ' + @fragmented + '] FROM narrow_index)'
EXEC (@sql)
SET @sql='DECLARE @a int SET @a=(SELECT COUNT_BIG(c1) AS [cl_ix_scan ' + @fragmented + '] FROM Wide)'
EXEC (@sql)

--Note size of index and frag level, should be comparative between executions
SELECT OBJECT_NAME(object_id), index_type_desc, CAST(avg_fragmentation_in_percent AS decimal(5,1)) AS frag, page_count/1000 AS page_count_1000s
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE index_level = 0 AND alloc_unit_type_desc = 'IN_ROW_DATA' AND OBJECT_NAME(object_id) IN('narrow_index','wide')
ORDER BY index_id
GO

--1: cause fragmentation in index
UPDATE wide SET c1=c3 WHERE c7%3=0;
UPDATE narrow_index SET c1 = c1 + 1 WHERE c1 % 100 = 0

--Run the queries
EXEC run_the_sql @fragmented = 'high_frag_level'
EXEC run_the_sql @fragmented = 'high_frag_level'
EXEC run_the_sql @fragmented = 'high_frag_level'
EXEC run_the_sql @fragmented = 'high_frag_level'

--2: no frag in either index, fillfactor set to make same size as when fragmented
ALTER INDEX x ON narrow_index REBUILD WITH (FILLFACTOR = 50)
ALTER INDEX cl_wide ON wide REBUILD WITH(FILLFACTOR = 50)
--Run the queries
EXEC run_the_sql @fragmented = 'low_frag_level'
EXEC run_the_sql @fragmented = 'low_frag_level'
EXEC run_the_sql @fragmented = 'low_frag_level'
EXEC run_the_sql @fragmented = 'low_frag_level'

--Reset
EXEC sp_configure 'cursor threshold', -1
RECONFIGURE
--Stop trace
ALTER EVENT SESSION ssd_frag_test ON SERVER STATE = STOP

--Work the trace data
--Extract into a temp table
DROP TABLE IF EXISTS myXeData
DROP TABLE IF EXISTS myXeData2
SELECT CAST(event_Data AS XML) AS StatementData
INTO myXeData
FROM sys.fn_xe_file_target_read_file('c:\sqldata\MSSQL15.MSSQLSERVER\MSSQL\Data\ssd_frag_test*.xel', NULL, NULL, NULL);
--SELECT * FROM #myXeData;
--Use XQuery to transform XML to a table
WITH t AS(
SELECT
StatementData.value('(event/data[@name="duration"]/value)[1]','bigint') / 1000 AS duration_ms
,StatementData.value('(event/data[@name="cpu_time"]/value)[1]','bigint') /1000 AS cpu_ms
,StatementData.value('(event/data[@name="physical_reads"]/value)[1]','bigint') AS physical_reads
,StatementData.value('(event/data[@name="logical_reads"]/value)[1]','bigint') AS logical_reads
,StatementData.value('(event/data[@name="statement"]/value)[1]','nvarchar(500)') AS statement_
FROM myXeData AS evts
WHERE StatementData.value('(event/data[@name="statement"]/value)[1]','nvarchar(500)') LIKE '%frag_level%'
),
t2 AS (
SELECT
CASE WHEN t.physical_reads = 0 THEN 'warm' ELSE 'cold' END AS cold_or_warm
,CASE WHEN t.statement_ LIKE '%cl_ix_scan_%' THEN 'wide index' ELSE 'narrow_index' END AS index_width
,CASE WHEN t.statement_ LIKE '%low_frag_level%' THEN 'n' ELSE 'y' END AS fragmented
,duration_ms
,cpu_ms
,physical_reads
,logical_reads
FROM t)
SELECT *
INTO myXeData2
FROM t2;
--Raw data from the trace
--SELECT * INTO performanceresults.dbo.ssdraw FROM myXeData2 ORDER BY index_width, cold_or_warm, fragmented
--Verify pretty consistent values in each quartet.
--If not, then something special occurred (checkppoint, or something external to SQL) -- delete that row.
--Get avg values and compare them
SELECT
t2.cold_or_warm
,t2.index_width
,t2.fragmented
,AVG(t2.duration_ms) AS duration_ms
,AVG(t2.cpu_ms) AS cpu_ms
,AVG(t2.physical_reads) AS physical_reads
,AVG(t2.logical_reads) AS logical_reads
--INTO performanceresults.dbo.ssdavg
FROM myXeData2 aS t2
GROUP BY t2.cold_or_warm, t2.index_width, t2.fragmented
ORDER BY cold_or_warm, index_width, fragmented

