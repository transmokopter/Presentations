CREATE TABLE [dbo].[DimGeography] (
    [GeographyKey]             INT            NOT NULL,
    [City]                     VARCHAR (30) NULL,
    [StateProvinceCode]        VARCHAR (3)  NULL,
    [StateProvinceName]        VARCHAR (50) NULL,
    [CountryRegionCode]        VARCHAR (3)  NULL,
    [EnglishCountryRegionName] VARCHAR (50) NULL,
    [SpanishCountryRegionName] VARCHAR (50) NULL,
    [FrenchCountryRegionName]  VARCHAR (50) NULL,
    [PostalCode]               VARCHAR (15) NULL,
    [SalesTerritoryKey]        INT           NULL,
    [IpAddressLocator]         VARCHAR (15) NULL
);
GO

ALTER TABLE [dbo].[DimGeography]
    ADD CONSTRAINT [PK_DimGeography_GeographyKey] PRIMARY KEY NONCLUSTERED ([GeographyKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimGeography]
    ADD CONSTRAINT [FK_DimGeography_DimSalesTerritory] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [dbo].[DimSalesTerritory] ([SalesTerritoryKey]) NOT ENFORCED;
GO

