CREATE TABLE [dbo].[DimOrganization] (
    [OrganizationKey]       INT            NOT NULL,
    [ParentOrganizationKey] INT           NULL,
    [PercentageOfOwnership] VARCHAR (16) NULL,
    [OrganizationName]      VARCHAR (50) NULL,
    [CurrencyKey]           INT           NULL
);
GO


ALTER TABLE [dbo].[DimOrganization]
    ADD CONSTRAINT [FK_DimOrganization_DimCurrency] FOREIGN KEY ([CurrencyKey]) REFERENCES [dbo].[DimCurrency] ([CurrencyKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimOrganization]
    ADD CONSTRAINT [PK_DimOrganization] PRIMARY KEY NONCLUSTERED ([OrganizationKey] ASC) NOT ENFORCED;
GO

