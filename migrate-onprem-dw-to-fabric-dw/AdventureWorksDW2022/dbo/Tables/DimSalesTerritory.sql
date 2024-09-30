CREATE TABLE [dbo].[DimSalesTerritory] (
    [SalesTerritoryKey]          INT              NOT NULL,
    [SalesTerritoryAlternateKey] INT             NULL,
    [SalesTerritoryRegion]       VARCHAR (50)   NOT NULL,
    [SalesTerritoryCountry]      VARCHAR (50)   NOT NULL,
    [SalesTerritoryGroup]        VARCHAR (50)   NULL,
    [SalesTerritoryImage]        varbinary(4000) NULL
);
GO

ALTER TABLE [dbo].[DimSalesTerritory]
    ADD CONSTRAINT [PK_DimSalesTerritory_SalesTerritoryKey] PRIMARY KEY NONCLUSTERED ([SalesTerritoryKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimSalesTerritory]
    ADD CONSTRAINT [AK_DimSalesTerritory_SalesTerritoryAlternateKey] UNIQUE NONCLUSTERED ([SalesTerritoryAlternateKey] ASC) NOT ENFORCED;
GO

