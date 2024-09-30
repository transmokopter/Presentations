CREATE TABLE [dbo].[FactInternetSales] (
    [ProductKey]            INT           NOT NULL,
    [OrderDateKey]          INT           NOT NULL,
    [DueDateKey]            INT           NOT NULL,
    [ShipDateKey]           INT           NOT NULL,
    [CustomerKey]           INT           NOT NULL,
    [PromotionKey]          INT           NOT NULL,
    [CurrencyKey]           INT           NOT NULL,
    [SalesTerritoryKey]     INT           NOT NULL,
    [SalesOrderNumber]      VARCHAR (20) NOT NULL,
    [SalesOrderLineNumber]  smallint       NOT NULL,
    [RevisionNumber]        smallint       NOT NULL,
    [OrderQuantity]         SMALLINT      NOT NULL,
    [UnitPrice]             numeric(14,4)         NOT NULL,
    [ExtendedAmount]        numeric(14,4)         NOT NULL,
    [DiscountAmount]        FLOAT    NOT NULL,
    [ProductStandardCost]   numeric(14,4)         NOT NULL,
    [TotalProductCost]      numeric(14,4)         NOT NULL,
    [SalesAmount]           numeric(14,4)         NOT NULL,
    [TaxAmt]                numeric(14,4)         NOT NULL,
    [Freight]               numeric(14,4)         NOT NULL,
    [CarrierTrackingNumber] VARCHAR (25) NULL,
    [CustomerPONumber]      VARCHAR (25) NULL,
    [OrderDate]             datetime2(6)      NULL,
    [DueDate]               datetime2(6)      NULL,
    [ShipDate]              datetime2(6)      NULL
);
GO


ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [FK_FactInternetSales_DimPromotion] FOREIGN KEY ([PromotionKey]) REFERENCES [dbo].[DimPromotion] ([PromotionKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [FK_FactInternetSales_DimCustomer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [FK_FactInternetSales_DimDate] FOREIGN KEY ([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [FK_FactInternetSales_DimCurrency] FOREIGN KEY ([CurrencyKey]) REFERENCES [dbo].[DimCurrency] ([CurrencyKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [FK_FactInternetSales_DimProduct] FOREIGN KEY ([ProductKey]) REFERENCES [dbo].[DimProduct] ([ProductKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSales]
    ADD CONSTRAINT [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber] PRIMARY KEY NONCLUSTERED ([SalesOrderNumber] ASC, [SalesOrderLineNumber] ASC) NOT ENFORCED;
GO

