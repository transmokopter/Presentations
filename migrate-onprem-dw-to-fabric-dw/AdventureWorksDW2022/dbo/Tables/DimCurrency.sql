CREATE TABLE [dbo].[DimCurrency] (
    [CurrencyKey]          INT            NOT NULL,
    [CurrencyAlternateKey] char (3)     NOT NULL,
    [CurrencyName]         VARCHAR (50) NOT NULL
);
GO

ALTER TABLE [dbo].[DimCurrency]
    ADD CONSTRAINT [PK_DimCurrency_CurrencyKey] PRIMARY KEY NONCLUSTERED ([CurrencyKey] ASC) NOT ENFORCED;
GO
