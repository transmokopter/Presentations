insert demo.productionsales_staging (referencedate,productidentification,productname,productshortname,warehouseidentification,
		warehouselocation,itemtype,ProductionCompanyIdentifier,ProductionCompanyName,ProductionCountry,ProductionCurrency,
		productionprice,salescurrency,GrossSalesPrice,AverageNetPrice,ItemsSold,ItemsOnStock,FileSource)
values ('2019-06-01','123','123','123','123','SE','stuff','123','123','SE','SEK',1,'SEK',1,1,1,1,'')
SELECT * FROM demo.productionsales_staging 

--Variables
DECLARE @p int --partition number
DECLARE @ReferenceDate date
DECLARE @inRange int --Used to check that ReferenceDate fits into partition
DECLARE @nextBound date --Next rightmost range value för partition function
declare @s nvarchar(max);

--Get referencedate from staging table
select @ReferenceDate=max(ReferenceDate) FROM demo.ProductionSales_Staging;

--Check if the partition number for ReferenceDate contains rows. If so, exit out later on.
SELECT @inRange=SUM([rows]) from sys.partitions 
WHERE object_id = OBJECT_ID('Demo.ProductionSales')
AND partition_number = $partition.pf_DEMO(@referenceDate);

--Reference date is not in an already existing partition
IF @inRange=0
BEGIN
	--Get the next bound. It will be one month later than ReferenceDate
	SET @nextBound = 
		dateadd(day,1,cast(eomonth(@ReferenceDate) as DATE));
	--Add check-constraint to the Staging table, to let SQL Server know all data will fit in empty partition
	--Must use dynamic SQL here
	SET @s=
		'ALTER TABLE Demo.ProductionSales_Staging 
		WITH CHECK ADD CONSTRAINT ProductionSales_bounds CHECK 
		(ReferenceDate>= ''' + cast(@ReferenceDate as nvarchar(100)) + ''' 
		AND ReferenceDate<''' + cast(@nextBound as nvarchar(100)) + ''')';
	exec sp_executesql @s;	
	--Tell SQL Server that the next filegroup to use for partition scheme shall be PRIMARY
	ALTER PARTITION SCHEME ps_DEMO NEXT USED [PRIMARY];
	--Split rightmost partition, by telling what the next range-value shall be
	set @s='ALTER PARTITION FUNCTION pf_DEMO() SPLIT RANGE(''' + cast(@nextBound as nvarchar(100)) + ''')';
	exec sp_executesql @s;
	--Get the partitionID of the partition for @ReferenceDate
	SET @p = $partition.pf_DEMO(@ReferenceDate);
	--Perform the actual SWITCH-operation
	SET @s=
		'ALTER TABLE demo.ProductionSales_Staging 
		SWITCH TO Demo.ProductionSales partition ' + cast(@p as nvarchar(100));
	exec sp_executesql @s;
	--Drop the CHECK constraint on the staging table, so it can be used for the next ReferenceDate
	ALTER TABLE Demo.ProductionSales_Staging DROP CONSTRAINT ProductionSales_bounds;
END
ELSE
BEGIN
	--If ReferenceDate already is in target table
	RAISERROR('Date in staging table is already in target table',16,1)
END


--Now, we have switched in the content of the staging table
--to the main table


--Check the content of the staging table
select * from demo.productionsales_staging;
--and the target table
select count(*),ReferenceDate,$partition.pf_demo(ReferenceDate) as PartitionNumber
from demo.productionsales
group by ReferenceDate;


--Visual Studio

