CREATE TABLE [dbo].[DimProductCategory] (
    [ProductCategoryKey]          INT            NOT NULL,
    [ProductCategoryAlternateKey] INT           NULL,
    [EnglishProductCategoryName]  VARCHAR (50) NOT NULL,
    [SpanishProductCategoryName]  VARCHAR (50) NOT NULL,
    [FrenchProductCategoryName]   VARCHAR (50) NOT NULL
);
GO

ALTER TABLE [dbo].[DimProductCategory]
    ADD CONSTRAINT [AK_DimProductCategory_ProductCategoryAlternateKey] UNIQUE NONCLUSTERED ([ProductCategoryAlternateKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimProductCategory]
    ADD CONSTRAINT [PK_DimProductCategory_ProductCategoryKey] PRIMARY KEY NONCLUSTERED ([ProductCategoryKey] ASC) NOT ENFORCED;
GO

