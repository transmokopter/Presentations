CREATE TABLE [dbo].[DimProduct] (
    [ProductKey]            INT              NOT NULL,
    [ProductAlternateKey]   VARCHAR (25)   NULL,
    [ProductSubcategoryKey] INT             NULL,
    [WeightUnitMeasureCode] char (3)       NULL,
    [SizeUnitMeasureCode]   char (3)       NULL,
    [EnglishProductName]    VARCHAR (50)   NOT NULL,
    [StandardCost]          numeric(14,4)           NULL,
    [FinishedGoodsFlag]     BIT             NOT NULL,
    [Color]                 VARCHAR (15)   NOT NULL,
    [SafetyStockLevel]      SMALLINT        NULL,
    [ReorderPoint]          SMALLINT        NULL,
    [ListPrice]             numeric(14,4)           NULL,
    [Size]                  VARCHAR (50)   NULL,
    [SizeRange]             VARCHAR (50)   NULL,
    [Weight]                FLOAT      NULL,
    [DaysToManufacture]     INT             NULL,
    [ProductLine]           char (2)       NULL,
    [DealerPrice]           numeric(14,4)           NULL,
    [Class]                 char (2)       NULL,
    [Style]                 char (2)       NULL,
    [ModelName]             VARCHAR (50)   NULL,
    [LargePhoto]            VARBINARY (4000) NULL,
    [EnglishDescription]    VARCHAR (400)  NULL,
    [StartDate]             datetime2(6)        NULL,
    [EndDate]               datetime2(6)       NULL,
    [Status]                VARCHAR (7)    NULL
);
GO

ALTER TABLE [dbo].[DimProduct]
    ADD CONSTRAINT [FK_DimProduct_DimProductSubcategory] FOREIGN KEY ([ProductSubcategoryKey]) REFERENCES [dbo].[DimProductSubcategory] ([ProductSubcategoryKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimProduct]
    ADD CONSTRAINT [AK_DimProduct_ProductAlternateKey_StartDate] UNIQUE NONCLUSTERED ([ProductAlternateKey] ASC, [StartDate] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimProduct]
    ADD CONSTRAINT [PK_DimProduct_ProductKey] PRIMARY KEY NONCLUSTERED ([ProductKey] ASC) NOT ENFORCED;
GO

