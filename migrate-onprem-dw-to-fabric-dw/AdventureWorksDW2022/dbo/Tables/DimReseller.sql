CREATE TABLE [dbo].[DimReseller] (
    [ResellerKey]          INT            NOT NULL,
    [GeographyKey]         INT           NULL,
    [ResellerAlternateKey] VARCHAR (15) NULL,
    [Phone]                VARCHAR (25) NULL,
    [BusinessType]         VARCHAR (20)  NOT NULL,
    [ResellerName]         VARCHAR (50) NOT NULL,
    [NumberEmployees]      INT           NULL,
    [OrderFrequency]       CHAR (1)      NULL,
    [OrderMonth]           smallint       NULL,
    [FirstOrderYear]       INT           NULL,
    [LastOrderYear]        INT           NULL,
    [ProductLine]          VARCHAR (50) NULL,
    [AddressLine1]         VARCHAR (60) NULL,
    [AddressLine2]         VARCHAR (60) NULL,
    [AnnualSales]          numeric(14,4)         NULL,
    [BankName]             VARCHAR (50) NULL,
    [MinPaymentType]       smallint       NULL,
    [MinPaymentAmount]     numeric(14,4)         NULL,
    [AnnualRevenue]        numeric(14,4)         NULL,
    [YearOpened]           INT           NULL
);
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [AK_DimReseller_ResellerAlternateKey] UNIQUE NONCLUSTERED ([ResellerAlternateKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [PK_DimReseller_ResellerKey] PRIMARY KEY NONCLUSTERED ([ResellerKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [FK_DimReseller_DimGeography] FOREIGN KEY ([GeographyKey]) REFERENCES [dbo].[DimGeography] ([GeographyKey]) NOT ENFORCED;
GO

