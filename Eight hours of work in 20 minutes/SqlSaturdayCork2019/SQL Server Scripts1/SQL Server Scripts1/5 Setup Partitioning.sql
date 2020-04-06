


use SqlSaturday433;
go
--First we need a partition function
--Let's look at how many partitions we need for the current content of the table

select distinct referencedate from Demo.ProductionSales;

--2019-01-01 is first referencedate. That's our first data-partition.
--Rightmost range value = 2019-01-01 + 1 month
--(because I want an empty rightmost partition)
--I also want an empty leftmost partition, 
--therefore I use 2013-10-31 as leftmost range value












--drop partition scheme ps_demo;
--drop partition function pf_demo;

CREATE PARTITION FUNCTION [pf_DEMO](date) AS RANGE RIGHT FOR VALUES 
	(
		N'2019-01-01', N'2019-02-01',N'2019-03-01');
GO

CREATE PARTITION SCHEME PS_DEMO AS PARTITION pf_DEMO ALL TO ('PRIMARY');
GO


--Check, with function $partition, which partition each 
--referencedate will fit into
SELECT DISTINCT 
	$partition.pf_demo(referencedate),
	referencedate from demo.productionsales;



















--Let's partition the table
--First drop clustered index
ALTER TABLE DEMO.ProductionSales 
	DROP CONSTRAINT PK_DEMO_ProductionSales;

--Clustered index needs to contain the clustering key, 
--in our case the ReferenceDate
ALTER TABLE DEMO.ProductionSales 
	ADD CONSTRAINT PK_DEMO_ProductionSales 
	PRIMARY KEY CLUSTERED
		(ReferenceDate, ProductionSalesID)
	WITH(DATA_COMPRESSION=PAGE) 
	ON PS_DEMO(ReferenceDate);

--Check partitions for the clustered index
SELECT * FROM 
	sys.partitions 
WHERE 
	object_id=OBJECT_ID('demo.productionsales') 
	AND index_id=1;

























--But what about non-clustered indexes?
SELECT * FROM 
	sys.partitions 
WHERE 
	object_id=OBJECT_ID('demo.productionsales') 
	AND index_id>1;


--So, let's rebuild those indexes on a partition scheme instead of PRIMARY
CREATE INDEX ix_ProductIdentification 
	ON DEMO.ProductionSales(ProductIdentification) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);
CREATE INDEX ix_ItemType 
	ON DEMO.ProductionSales(ItemType) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_ProductionCompanyIdentifier 
	ON DEMO.ProductionSales(ProductionCompanyIdentifier) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_ProductionCurrency 
	ON DEMO.ProductionSales(ProductionCurrency) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_ProductionCountry 
	ON DEMO.ProductionSales(ProductionCountry) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_WarehouseIdentification 
	ON DEMO.ProductionSales(WarehouseIdentification) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_WarehouseLocation 
	ON DEMO.ProductionSales(WarehouseLocation) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);

CREATE INDEX ix_SalesCurrency 
	ON DEMO.ProductionSales(SalesCurrency) 
	WITH (DROP_EXISTING=ON, DATA_COMPRESSION=PAGE) 
	ON  PS_DEMO(ReferenceDate);


--Check partitions again
SELECT * FROM 
	sys.partitions 
WHERE 
	object_id=OBJECT_ID('demo.productionsales') 
	AND index_id>1;


	SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('demo.productionsales') AND index_id=3
	ALTER TABLE demo.productionsales DROP CONSTRAINT UQ_DEMO_ProductionSales
	DROP INDEX UQ_DEMO_ProductionSales ON demo.productionsales








--Index_id=2 is still only on one partition. 
--Let's find out which index it is
SELECT 
	* 
FROM 
	sys.indexes 
WHERE 
	object_id=OBJECT_ID('demo.productionsales') 
	and index_id=2;

--Aha, the unique constraint is of course also an index
ALTER TABLE Demo.ProductionSales 
	DROP CONSTRAINT UQ_DEMO_ProductionSales;

ALTER TABLE DEMO.ProductionSales 
	ADD  CONSTRAINT [UQ_DEMO_ProductionSales] UNIQUE NONCLUSTERED 
	(
		ReferenceDate ASC,
		ProductIdentification ASC,
		WarehouseIdentification ASC,
		ProductionCompanyIdentifier ASC
	) WITH( DATA_COMPRESSION=PAGE) ON PS_DEMO(ReferenceDate);

--Now, we have a partitioned table!
--Next up: Create a staging table





























CREATE TABLE Demo.ProductionSales_STAGING(
	[ReferenceDate] [date] NOT NULL,
	ProductionSalesID bigint identity(1,1) NOT NULL,
	[ProductIdentification] [varchar](13) NOT NULL,
	[ProductName] varchar(100),
	ProductShortName varchar(45),
	WarehouseIdentification varchar(20) NOT NULL,
	WarehouseLocation char(2) NULL, --Country of warehouse
	[ItemType] [char](5) NULL,
	ProductionCompanyIdentifier varchar(20) NOT NULL,
	ProductionCompanyName varchar(20) NULL,
	ProductionCountry char(2) NOT NULL,
	[ProductionCurrency] [char](3) NOT NULL,
	[ProductionPrice] int NULL,
	SalesCurrency char(3) NOT NULL,
	[GrossSalesPrice] int NULL,
	[AverageNetPrice] int NULL,
	ItemsSold int NULL,
	ItemsOnStock int NULL,
	[FileSource] [nvarchar](500) NULL,
	[SSIS_Insert_DT] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT PK_DEMO_ProductionSales_STAGING PRIMARY KEY CLUSTERED 
(
	ReferenceDate ASC,
	ProductionSalesID ASC
)WITH(DATA_COMPRESSION=PAGE),
 CONSTRAINT [UQ_DEMO_ProductionSales_STAGING] UNIQUE NONCLUSTERED 
(
	ReferenceDate ASC,
	ProductIdentification ASC,
	WarehouseIdentification ASC,
	ProductionCompanyIdentifier ASC
) WITH(DATA_COMPRESSION=PAGE) ON [PRIMARY]
) ON [PRIMARY];

















--Now we have a staging table, 
--identical to our ProductionSales table
--Except one thing: There are no non clustered 
--indexes on the table. They need to be there as well.

CREATE INDEX ix_ProductIdentification 
	ON DEMO.ProductionSales_Staging(ProductIdentification)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_ItemType 
	ON DEMO.ProductionSales_Staging(ItemType)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_ProductionCompanyIdentifier 
	ON DEMO.ProductionSales_Staging(ProductionCompanyIdentifier)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_ProductionCurrency 
	ON DEMO.ProductionSales_Staging(ProductionCurrency)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_ProductionCountry 
	ON DEMO.ProductionSales_Staging(ProductionCountry)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_WarehouseIdentification 
	ON DEMO.ProductionSales_Staging(WarehouseIdentification)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_WarehouseLocation 
	ON DEMO.ProductionSales_Staging(WarehouseLocation)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

CREATE INDEX ix_SalesCurrency 
	ON DEMO.ProductionSales_Staging(SalesCurrency)
	WITH(DATA_COMPRESSION=PAGE) 
	ON  [PRIMARY];

ALTER TABLE demo.ProductionSales_STAGING DROP CONSTRAINT UQ_DEMO_ProductionSales_STAGING 
--Partitioning is done!