CREATE TABLE [dbo].[DimCustomer] (
    [CustomerKey]          INT             NOT NULL,
    [GeographyKey]         INT            NULL,
    [CustomerAlternateKey] VARCHAR (15)  NOT NULL,
    [Title]                VARCHAR (8)   NULL,
    [FirstName]            VARCHAR (50)  NULL,
    [MiddleName]           VARCHAR (50)  NULL,
    [LastName]             VARCHAR (50)  NULL,
    [NameStyle]            BIT            NULL,
    [BirthDate]            DATE           NULL,
    [MaritalStatus]        char (1)      NULL,
    [Suffix]               VARCHAR (10)  NULL,
    [Gender]               VARCHAR (1)   NULL,
    [EmailAddress]         VARCHAR (50)  NULL,
    [YearlyIncome]         numeric(14,4)          NULL,
    [TotalChildren]        smallint        NULL,
    [NumberChildrenAtHome] smallint        NULL,
    [EnglishEducation]     VARCHAR (40)  NULL,
    [SpanishEducation]     VARCHAR (40)  NULL,
    [FrenchEducation]      VARCHAR (40)  NULL,
    [EnglishOccupation]    VARCHAR (100) NULL,
    [SpanishOccupation]    VARCHAR (100) NULL,
    [FrenchOccupation]     VARCHAR (100) NULL,
    [HouseOwnerFlag]       char (1)      NULL,
    [NumberCarsOwned]      smallint        NULL,
    [AddressLine1]         VARCHAR (120) NULL,
    [AddressLine2]         VARCHAR (120) NULL,
    [Phone]                VARCHAR (20)  NULL,
    [DateFirstPurchase]    DATE           NULL,
    [CommuteDistance]      VARCHAR (15)  NULL
);
GO

ALTER TABLE [dbo].[DimCustomer]
    ADD CONSTRAINT [FK_DimCustomer_DimGeography] FOREIGN KEY ([GeographyKey]) REFERENCES [dbo].[DimGeography] ([GeographyKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimCustomer]
    ADD CONSTRAINT [PK_DimCustomer_CustomerKey] PRIMARY KEY NONCLUSTERED ([CustomerKey] ASC) NOT ENFORCED;
GO

