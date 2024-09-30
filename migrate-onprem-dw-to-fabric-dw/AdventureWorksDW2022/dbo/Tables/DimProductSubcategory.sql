CREATE TABLE [dbo].[DimProductSubcategory] (
    [ProductSubcategoryKey]          INT            NOT NULL,
    [ProductSubcategoryAlternateKey] INT           NULL,
    [EnglishProductSubcategoryName]  VARCHAR (50) NOT NULL,
    [SpanishProductSubcategoryName]  VARCHAR (50) NOT NULL,
    [FrenchProductSubcategoryName]   VARCHAR (50) NOT NULL,
    [ProductCategoryKey]             INT           NULL
);
GO

ALTER TABLE [dbo].[DimProductSubcategory]
    ADD CONSTRAINT [PK_DimProductSubcategory_ProductSubcategoryKey] PRIMARY KEY NONCLUSTERED ([ProductSubcategoryKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimProductSubcategory]
    ADD CONSTRAINT [AK_DimProductSubcategory_ProductSubcategoryAlternateKey] UNIQUE NONCLUSTERED ([ProductSubcategoryAlternateKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimProductSubcategory]
    ADD CONSTRAINT [FK_DimProductSubcategory_DimProductCategory] FOREIGN KEY ([ProductCategoryKey]) REFERENCES [dbo].[DimProductCategory] ([ProductCategoryKey]) NOT ENFORCED;
GO

