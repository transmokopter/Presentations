ALTER DATABASE SqlServerWorstPractices SET AUTO_SHRINK ON;


CREATE TABLE dbo.MyTransactionTable(
	id INT NOT NULL CONSTRAINT PK_MyTransactionTable PRIMARY KEY CLUSTERED,
	c1 VARCHAR(40));
CREATE INDEX ix_MyTransactionTable_c1 ON dbo.MyTransactionTable(c1) WITH(DATA_COMPRESSION=PAGE);

INSERT dbo.MyTransactionTable
(
    id,
    c1
)
SELECT value,CAST(NEWID() AS VARCHAR(40))
FROM generate_series(1,10000000,1);

EXEC sp_spaceused


TRUNCATE TABLE dbo.MyTransactionTable;
CHECKPOINT;
--now we wait. Let's do something else in the meantime and then come back.


EXEC sp_spaceused


INSERT dbo.MyTransactionTable
(
    id,
    c1
)
SELECT value,CAST(NEWID() AS VARCHAR(40))
FROM generate_series(1,10000000,1);
