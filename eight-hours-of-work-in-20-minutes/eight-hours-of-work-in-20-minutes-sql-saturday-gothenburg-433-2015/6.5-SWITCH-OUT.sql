--Let's make sure staging table is empty
TRUNCATE TABLE DEMO.ProductionSales_Staging
--...and that there are no check constraints left from previous operations
SELECT * FROM sys.check_constraints where object_id=object_id('demo.productionsales_staging');

--Look at partition numbers for old data
SELECT distinct $partition.pf_demo(ReferenceDate)
FROM Demo.ProductionSales
WHERE ReferenceDate='2013-10-31';

--So, then we switch partition number 2 to the staging table
ALTER TABLE demo.ProductionSales
	SWITCH PARTITION 2 TO
	Demo.ProductionSales_Staging;

--Check what we have in Staging table and target table
SELECT 
	COUNT(*) as RowsInTargetTable,ReferenceDate  
FROM 
	Demo.ProductionSales 
GROUP BY
	ReferenceDate;


SELECT 
	COUNT(*) as RowsInStagingTable,ReferenceDate  
FROM 
	Demo.ProductionSales_STAGING 
GROUP BY
	ReferenceDate;

--All data from 2013-10-31 moved to staging table.
--Let's get rid of it
TRUNCATE TABLE Demo.ProductionSales_STAGING;

--Did the switch leave any check constraints in staging table?
SELECT * 
FROM sys.check_constraints
WHERE object_id=object_id('demo.productionsales_staging');


--What about leftover partitions?
SELECT *
FROM sys.partitions
where index_id=1
AND object_id=object_id('demo.productionsales')
ORDER BY partition_number;


--We might want to merge partition 1 and partition 2
--That's done by MERGING the leftmost partition range value
--So, we look first a range values
SELECT * FROM sys.partition_range_values;

--And now merge
ALTER PARTITION FUNCTION pf_DEMO()
MERGE RANGE('2013-10-31');

--Check remaining partitions and range values again
SELECT *
FROM sys.partitions
WHERE index_id=1
AND object_id=OBJECT_ID('demo.productionsales')
ORDER BY partition_number;


SELECT * FROM sys.partition_range_values;
