CREATE TABLE [dbo].[DimSalesReason] (
    [SalesReasonKey]          INT            NOT NULL,
    [SalesReasonAlternateKey] INT           NOT NULL,
    [SalesReasonName]         VARCHAR (50) NOT NULL,
    [SalesReasonReasonType]   VARCHAR (50) NOT NULL
);
GO

ALTER TABLE [dbo].[DimSalesReason]
    ADD CONSTRAINT [PK_DimSalesReason_SalesReasonKey] PRIMARY KEY NONCLUSTERED ([SalesReasonKey] ASC) NOT ENFORCED;
GO

