--Create partition function for four partitions.
--Use range right
CREATE PARTITION FUNCTION 
	ForIntegersRight
		(int) AS RANGE RIGHT 
FOR VALUES
(0,10,100);

--Same range values, but range left
CREATE PARTITION FUNCTION ForIntegersLeft(int) AS RANGE LEFT FOR VALUES
(0,10,100);

--First test value smaller than lowest range value
SELECT 
	$partition.ForIntegersRight(-1) as [RangeRight -1],
	$partition.ForIntegersLeft(-1) as [RangeLeft -1];


--Test functcion using some on- and close to-range values.
SELECT 
	$partition.ForIntegersRight(0) as [RangeRight 0],
	$partition.ForIntegersLeft(0) as [RangeLeft 0],
	$partition.ForIntegersRight(1) as [Range Right 1],
	$partition.ForIntegersLeft(1) as [Range Left 1],
	$partition.ForIntegersRight(10) as [RangeRight 10],
	$partition.ForIntegersLeft(10) as [RangeLeft 10],
	$partition.ForIntegersRight(100) as [RangeRight 100],
	$partition.ForIntegersLeft(100) as [RangeLeft 100],
	$partition.ForIntegersRight(101) as [RangeRight 101],
	$partition.ForIntegersLeft(101) as [RangeLeft 101];

