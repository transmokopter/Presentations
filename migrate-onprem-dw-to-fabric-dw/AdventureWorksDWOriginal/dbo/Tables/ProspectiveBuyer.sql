CREATE TABLE [dbo].[ProspectiveBuyer] (
    [ProspectiveBuyerKey]  INT            IDENTITY (1, 1) NOT NULL,
    [ProspectAlternateKey] NVARCHAR (15)  NULL,
    [FirstName]            NVARCHAR (50)  NULL,
    [MiddleName]           NVARCHAR (50)  NULL,
    [LastName]             NVARCHAR (50)  NULL,
    [BirthDate]            DATETIME       NULL,
    [MaritalStatus]        NCHAR (1)      NULL,
    [Gender]               NVARCHAR (1)   NULL,
    [EmailAddress]         NVARCHAR (50)  NULL,
    [YearlyIncome]         MONEY          NULL,
    [TotalChildren]        TINYINT        NULL,
    [NumberChildrenAtHome] TINYINT        NULL,
    [Education]            NVARCHAR (40)  NULL,
    [Occupation]           NVARCHAR (100) NULL,
    [HouseOwnerFlag]       NCHAR (1)      NULL,
    [NumberCarsOwned]      TINYINT        NULL,
    [AddressLine1]         NVARCHAR (120) NULL,
    [AddressLine2]         NVARCHAR (120) NULL,
    [City]                 NVARCHAR (30)  NULL,
    [StateProvinceCode]    NVARCHAR (3)   NULL,
    [PostalCode]           NVARCHAR (15)  NULL,
    [Phone]                NVARCHAR (20)  NULL,
    [Salutation]           NVARCHAR (8)   NULL,
    [Unknown]              INT            NULL
);
GO

ALTER TABLE [dbo].[ProspectiveBuyer]
    ADD CONSTRAINT [PK_ProspectiveBuyer_ProspectiveBuyerKey] PRIMARY KEY CLUSTERED ([ProspectiveBuyerKey] ASC);
GO

