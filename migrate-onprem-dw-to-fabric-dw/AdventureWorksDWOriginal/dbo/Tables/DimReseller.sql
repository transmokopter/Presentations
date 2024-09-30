CREATE TABLE [dbo].[DimReseller] (
    [ResellerKey]          INT           IDENTITY (1, 1) NOT NULL,
    [GeographyKey]         INT           NULL,
    [ResellerAlternateKey] NVARCHAR (15) NULL,
    [Phone]                NVARCHAR (25) NULL,
    [BusinessType]         VARCHAR (20)  NOT NULL,
    [ResellerName]         NVARCHAR (50) NOT NULL,
    [NumberEmployees]      INT           NULL,
    [OrderFrequency]       CHAR (1)      NULL,
    [OrderMonth]           TINYINT       NULL,
    [FirstOrderYear]       INT           NULL,
    [LastOrderYear]        INT           NULL,
    [ProductLine]          NVARCHAR (50) NULL,
    [AddressLine1]         NVARCHAR (60) NULL,
    [AddressLine2]         NVARCHAR (60) NULL,
    [AnnualSales]          MONEY         NULL,
    [BankName]             NVARCHAR (50) NULL,
    [MinPaymentType]       TINYINT       NULL,
    [MinPaymentAmount]     MONEY         NULL,
    [AnnualRevenue]        MONEY         NULL,
    [YearOpened]           INT           NULL
);
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [AK_DimReseller_ResellerAlternateKey] UNIQUE NONCLUSTERED ([ResellerAlternateKey] ASC);
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [PK_DimReseller_ResellerKey] PRIMARY KEY CLUSTERED ([ResellerKey] ASC);
GO

ALTER TABLE [dbo].[DimReseller]
    ADD CONSTRAINT [FK_DimReseller_DimGeography] FOREIGN KEY ([GeographyKey]) REFERENCES [dbo].[DimGeography] ([GeographyKey]);
GO

