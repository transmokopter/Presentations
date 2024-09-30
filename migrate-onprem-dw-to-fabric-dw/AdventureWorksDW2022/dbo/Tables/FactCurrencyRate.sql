CREATE TABLE [dbo].[FactCurrencyRate] (
    [CurrencyKey]  INT        NOT NULL,
    [DateKey]      INT        NOT NULL,
    [AverageRate]  FLOAT NOT NULL,
    [EndOfDayRate] FLOAT NOT NULL,
    [Date]         datetime2(6)   NULL
);
GO

ALTER TABLE [dbo].[FactCurrencyRate]
    ADD CONSTRAINT [FK_FactCurrencyRate_DimDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactCurrencyRate]
    ADD CONSTRAINT [FK_FactCurrencyRate_DimCurrency] FOREIGN KEY ([CurrencyKey]) REFERENCES [dbo].[DimCurrency] ([CurrencyKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactCurrencyRate]
    ADD CONSTRAINT [PK_FactCurrencyRate_CurrencyKey_DateKey] PRIMARY KEY NONCLUSTERED ([CurrencyKey] ASC, [DateKey] ASC) NOT ENFORCED;
GO

