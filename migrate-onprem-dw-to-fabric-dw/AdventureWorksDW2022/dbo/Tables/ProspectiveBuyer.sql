
GO
CREATE TABLE [dbo].[ProspectiveBuyer] (
    [ProspectiveBuyerKey]  INT           NOT NULL,
    [ProspectAlternateKey] VARCHAR (15)  NULL,
    [FirstName]            VARCHAR (50)  NULL,
    [MiddleName]           VARCHAR (50)  NULL,
    [LastName]             VARCHAR (50)  NULL,
    [BirthDate]            datetime2(6)       NULL,
    [MaritalStatus]        CHAR (1)      NULL,
    [Gender]               VARCHAR (1)   NULL,
    [EmailAddress]         VARCHAR (50)  NULL,
    [YearlyIncome]         numeric(14,4)          NULL,
    [TotalChildren]        smallint        NULL,
    [NumberChildrenAtHome] smallint        NULL,
    [Education]            VARCHAR (40)  NULL,
    [Occupation]           VARCHAR (100) NULL,
    [HouseOwnerFlag]       CHAR (1)      NULL,
    [NumberCarsOwned]      smallint        NULL,
    [AddressLine1]         VARCHAR (120) NULL,
    [AddressLine2]         VARCHAR (120) NULL,
    [City]                 VARCHAR (30)  NULL,
    [StateProvinceCode]    VARCHAR (3)   NULL,
    [PostalCode]           VARCHAR (15)  NULL,
    [Phone]                VARCHAR (20)  NULL,
    [Salutation]           VARCHAR (8)   NULL,
    [Unknown]              INT            NULL
);
GO

ALTER TABLE [dbo].[ProspectiveBuyer]
    ADD CONSTRAINT [PK_ProspectiveBuyer_ProspectiveBuyerKey] PRIMARY KEY NONCLUSTERED ([ProspectiveBuyerKey] ASC) NOT ENFORCED;
GO

