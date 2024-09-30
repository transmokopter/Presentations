CREATE TABLE [dbo].[FactInternetSalesReason] (
    [SalesOrderNumber]     VARCHAR (20) NOT NULL,
    [SalesOrderLineNumber] smallint       NOT NULL,
    [SalesReasonKey]       INT           NOT NULL
);
GO

ALTER TABLE [dbo].[FactInternetSalesReason]
    ADD CONSTRAINT [FK_FactInternetSalesReason_FactInternetSales] FOREIGN KEY ([SalesOrderNumber], [SalesOrderLineNumber]) REFERENCES [dbo].[FactInternetSales] ([SalesOrderNumber], [SalesOrderLineNumber]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSalesReason]
    ADD CONSTRAINT [FK_FactInternetSalesReason_DimSalesReason] FOREIGN KEY ([SalesReasonKey]) REFERENCES [dbo].[DimSalesReason] ([SalesReasonKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactInternetSalesReason]
    ADD CONSTRAINT [PK_FactInternetSalesReason_SalesOrderNumber_SalesOrderLineNumber_SalesReasonKey] PRIMARY KEY NONCLUSTERED ([SalesOrderNumber] ASC, [SalesOrderLineNumber] ASC, [SalesReasonKey] ASC) NOT ENFORCED;
GO

