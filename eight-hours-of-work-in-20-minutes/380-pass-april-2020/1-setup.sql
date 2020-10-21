:setvar executionNo "3"
use master
go
if '1'='$(executionNo)'
BEGIN
		drop database if exists sqlsaturday433;
		create database sqlsaturday433;
	ALTER DATABASE [sqlsaturday433] SET RECOVERY SIMPLE WITH NO_WAIT
	ALTER DATABASE [sqlsaturday433] MODIFY FILE 
		( NAME = N'sqlsaturday433', FILEGROWTH = 1024000KB, SIZE=2048000KB )
	ALTER DATABASE [sqlsaturday433] 
		MODIFY FILE ( NAME = N'sqlsaturday433_log', FILEGROWTH = 512000KB, SIZE = 2048000KB)
END

GO
use SqlSaturday433;
GO

if '1'='$(executionNo)'
BEGIN
	declare @s nvarchar(max)='CREATE SCHEMA Demo';
	exec sp_executesql @s;
END
GO

if '1'='$(executionNo)'
BEGIN

	CREATE TABLE Demo.ProductionSales(
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
	 CONSTRAINT PK_DEMO_ProductionSales PRIMARY KEY CLUSTERED 
	(
		ProductionSalesID ASC
	)WITH(DATA_COMPRESSION=PAGE)
	)  ON [PRIMARY];
END
GO
--After the first execution of Load Data Simple, create this constraint
if '2'='$(executionNo)'
BEGIN

	ALTER TABLE Demo.ProductionSales 
		ADD CONSTRAINT [UQ_DEMO_ProductionSales] UNIQUE NONCLUSTERED 
	(
		ReferenceDate ASC,
		ProductIdentification ASC,
		WarehouseIdentification ASC,
		ProductionCompanyIdentifier ASC
	)WITH(DATA_COMPRESSION=PAGE) ON [PRIMARY]
END

if '3'='$(executionNo)'
BEGIN
	--After the second execution of Load Data Simple, create these indexes 
	CREATE INDEX ix_ProductIdentification ON DEMO.ProductionSales(ProductIdentification)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_ItemType ON DEMO.ProductionSales(ItemType) WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_ProductionCompanyIdentifier ON DEMO.ProductionSales(ProductionCompanyIdentifier)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_ProductionCurrency ON DEMO.ProductionSales(ProductionCurrency)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_ProductionCountry ON DEMO.ProductionSales(ProductionCountry)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_WarehouseIdentification ON DEMO.ProductionSales(WarehouseIdentification)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_WarehouseLocation ON DEMO.ProductionSales(WarehouseLocation)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
	CREATE INDEX ix_SalesCurrency ON DEMO.ProductionSales(SalesCurrency)WITH(DATA_COMPRESSION=PAGE) ON  [PRIMARY];
END
GO

if '1'='$(executionNo)'
BEGIN

	CREATE TABLE DEMO.Product(
		ProductIdentification varchar(13) PRIMARY KEY,
		ProductName varchar(100),
		ProductShortName varchar(45),
		ItemType char(5)
	);
	CREATE TABLE DEMO.Warehouse (
		WarehouseIdentification varchar(20) PRIMARY KEY,
		WarehouseLocation char(2),
		SalesCurrency char(3)
	);
	CREATE TABLE DEMO.ProductionCompany(
		ProductionCompanyIdentifier varchar(20) PRIMARY KEY,
		ProductionCompanyName varchar(20) NULL,
		ProductionCountry char(2) NOT NULL,
		ProductionCurrency char(3));


	with cte as (
		select 1 as n	UNION ALL
		select 1	UNION ALL	select 1	UNION ALL	select 1	UNION ALL	select 1	UNION ALL
		select 1	UNION ALL	select 1	UNION ALL	select 1	UNION ALL	select 1	UNION ALL
		select 1	UNION ALL	select 1	UNION ALL	select 1	UNION ALL	select 1	
	),cte2 as (
		select row_number() over(order by n) as n FROM CTE 
	)
	insert DEMO.Product(ProductIdentification,ProductName,ProductShortName,ItemType)
	select 
		p.productnumber  +  char(cte2.n +64) + cast(cte3.n as varchar(2)),
		left(p.name,36) + ' series ' + char(cte2.n + 64) + cast(cte3.n as varchar(2)),
		psc.name ,
		left(pc.name,5) 
	from 
		adventureworks2014.production.Product p 
		INNER JOIN AdventureWorks2014.Production.ProductModel pm ON p.ProductModelID = pm.ProductModelID
		INNER JOIN AdventureWorks2014.Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
		INNER JOIN AdventureWorks2014.Production.ProductCategory pc ON psc.ProductCategoryID=pc.ProductCategoryID
	cross join cte2
	cross join cte2 as cte3
	order by len(p.name) desc



	insert demo.WareHouse (WarehouseIdentification,WarehouseLocation,SalesCurrency)
	values	('SE_ENKOPING','SE','SEK'),
			('NO_OSLO','NO','NOK'),
			('NL_ROTTERDAM','NL','EUR'),
			('DE_MUNICH','DE','EUR'),
			('US_NEWYORK','US','USD');

	INSERT DEMO.ProductionCompany	(ProductionCompanyIdentifier,ProductionCompanyName,ProductionCountry,ProductionCurrency)
	VALUES							('Monark_SE','Monark','SE','SEK'),
									('Monark_DK','Monark','DK','DKK'),
									('Crescent_BE','Crescent','BE','EUR'),
									('Adidas_DE','Adidas','DE','EUR'),
									('Shimano_JP','Shimano','JP','JPY'),
									('Shimano_CN','Shimano','CN','CNY'),
									('Adidas_TW','Adidas','TW','TWD'),
									('Gucci_IT','Gucci','IT','EUR');
END
GO


CREATE OR ALTER PROC Demo.GenerateCSV(@dt date)
AS
	select
	@dt AS ReferenceDate,
	p.ProductIdentification,
	p.ProductName,
	p.ProductShortName,
	w.WarehouseIdentification,
	w.WarehouseLocation,
	p.ItemType,
	pc.ProductionCompanyIdentifier,
	pc.productioncompanyname,
	pc.ProductionCountry,
	pc.productioncurrency,
	cast(ABS(CHECKSUM(NewId())) % 500 as varchar(20)) as ProductionPrice,
	w.SalesCurrency,
	cast(ABS(CHECKSUM(NewId())) % 1000 as varchar(20)) as GrossSalesPrice,
	cast(ABS(CHECKSUM(NewId())) % 800 as varchar(20)) as AverageNetPrice,
	cast(ABS(CHECKSUM(NewId())) % 5000 as varchar(20)) as ItemsSold,
	cast(ABS(CHECKSUM(NewId())) % 300 as varchar(20)) as ItemsOnStock
from demo.product p
cross join demo.productioncompany pc
cross join demo.warehouse w;
GO
