CREATE TABLE [dbo].[FactSalesQuota] (
    [SalesQuotaKey]    INT       NOT NULL,
    [EmployeeKey]      INT      NOT NULL,
    [DateKey]          INT      NOT NULL,
    [CalendarYear]     SMALLINT NOT NULL,
    [CalendarQuarter]  smallint  NOT NULL,
    [SalesAmountQuota] numeric(14,4)    NOT NULL,
    [Date]             datetime2(6) NULL
);
GO

ALTER TABLE [dbo].[FactSalesQuota]
    ADD CONSTRAINT [FK_FactSalesQuota_DimEmployee] FOREIGN KEY ([EmployeeKey]) REFERENCES [dbo].[DimEmployee] ([EmployeeKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactSalesQuota]
    ADD CONSTRAINT [FK_FactSalesQuota_DimDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactSalesQuota]
    ADD CONSTRAINT [PK_FactSalesQuota_SalesQuotaKey] PRIMARY KEY NONCLUSTERED ([SalesQuotaKey] ASC) NOT ENFORCED;
GO

