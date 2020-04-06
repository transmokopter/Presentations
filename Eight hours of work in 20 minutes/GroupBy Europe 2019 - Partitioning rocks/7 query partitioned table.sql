
--Count occurences of ItemType='Bikes' for specific ReferenceDate
SELECT 
	COUNT(*)
FROM
	Demo.ProductionSales 
WHERE
	ReferenceDate ='2019-03-01' option(recompile)



--Max(ProductCompanyIdentifier)
SET STATISTICS IO ON
SELECT 
	MAX(ProductionCompanyIdentifier)
FROM
	Demo.ProductionSales
OPTION(MAXDOP 1)
SET STATISTICS IO OFF




--Much more complex query, which uses partition-meta-data about the table
SET STATISTICS IO ON;
WITH CTE_Partitions AS(
	SELECT
		partition_number
	FROM
		sys.partitions p
	WHERE p.object_id=object_id('Demo.ProductionSales')
AND p.index_id = 1
),CTE_ProductionSales AS(
	SELECT 
		s.ProductionCompanyIdentifier
	FROM
		CTE_Partitions p
		CROSS APPLY(
			SELECT 
				MAX(ProductionCompanyIdentifier) as ProductionCompanyIdentifier
			FROM 
				Demo.ProductionSales 
			WHERE $PARTITION.pf_demo(ReferenceDate) = p.partition_number) AS s
)
SELECT MAX(ProductionCompanyIdentifier)
FROM CTE_ProductionSales;
SET STATISTICS IO OFF
