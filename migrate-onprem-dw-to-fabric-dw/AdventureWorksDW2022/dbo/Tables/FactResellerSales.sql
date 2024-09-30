CREATE TABLE [dbo].[FactResellerSales] (
    [ProductKey]            INT           NOT NULL,
    [OrderDateKey]          INT           NOT NULL,
    [DueDateKey]            INT           NOT NULL,
    [ShipDateKey]           INT           NOT NULL,
    [ResellerKey]           INT           NOT NULL,
    [EmployeeKey]           INT           NOT NULL,
    [PromotionKey]          INT           NOT NULL,
    [CurrencyKey]           INT           NOT NULL,
    [SalesTerritoryKey]     INT           NOT NULL,
    [SalesOrderNumber]      VARCHAR (20) NOT NULL,
    [SalesOrderLineNumber]  smallint       NOT NULL,
    [RevisionNumber]        smallint       NULL,
    [OrderQuantity]         SMALLINT      NULL,
    [UnitPrice]             numeric(14,4)         NULL,
    [ExtendedAmount]        numeric(14,4)         NULL,
    [UnitPriceDiscountPct]  FLOAT    NULL,
    [DiscountAmount]        FLOAT    NULL,
    [ProductStandardCost]   numeric(14,4)         NULL,
    [TotalProductCost]      numeric(14,4)         NULL,
    [SalesAmount]           numeric(14,4)         NULL,
    [TaxAmt]                numeric(14,4)         NULL,
    [Freight]               numeric(14,4)         NULL,
    [CarrierTrackingNumber] VARCHAR (25) NULL,
    [CustomerPONumber]      VARCHAR (25) NULL,
    [OrderDate]             datetime2(6)      NULL,
    [DueDate]               datetime2(6)      NULL,
    [ShipDate]              datetime2(6)      NULL
);
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [FK_FactResellerSales_DimPromotion] FOREIGN KEY ([PromotionKey]) REFERENCES [dbo].[DimPromotion] ([PromotionKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [FK_FactResellerSales_DimDate] FOREIGN KEY ([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [FK_FactResellerSales_DimProduct] FOREIGN KEY ([ProductKey]) REFERENCES [dbo].[DimProduct] ([ProductKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [FK_FactResellerSales_DimReseller] FOREIGN KEY ([ResellerKey]) REFERENCES [dbo].[DimReseller] ([ResellerKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [FK_FactResellerSales_DimCurrency] FOREIGN KEY ([CurrencyKey]) REFERENCES [dbo].[DimCurrency] ([CurrencyKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactResellerSales]
    ADD CONSTRAINT [PK_FactResellerSales_SalesOrderNumber_SalesOrderLineNumber] PRIMARY KEY NONCLUSTERED ([SalesOrderNumber] ASC, [SalesOrderLineNumber] ASC) NOT ENFORCED;
GO

