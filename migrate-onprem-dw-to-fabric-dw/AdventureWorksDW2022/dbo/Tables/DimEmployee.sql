CREATE TABLE [dbo].[DimEmployee] (
    [EmployeeKey]                          INT              NOT NULL,
    [ParentEmployeeKey]                    INT             NULL,
    [EmployeeNationalIDAlternateKey]       VARCHAR (15)   NULL,
    [ParentEmployeeNationalIDAlternateKey] VARCHAR (15)   NULL,
    [SalesTerritoryKey]                    INT             NULL,
    [FirstName]                            VARCHAR (50)   NOT NULL,
    [LastName]                             VARCHAR (50)   NOT NULL,
    [MiddleName]                           VARCHAR (50)   NULL,
    [NameStyle]                            BIT             NOT NULL,
    [Title]                                VARCHAR (50)   NULL,
    [HireDate]                             DATE            NULL,
    [BirthDate]                            DATE            NULL,
    [LoginID]                              VARCHAR (256)  NULL,
    [EmailAddress]                         VARCHAR (50)   NULL,
    [Phone]                                VARCHAR (25)   NULL,
    [MaritalStatus]                        char (1)       NULL,
    [EmergencyContactName]                 VARCHAR (50)   NULL,
    [EmergencyContactPhone]                VARCHAR (25)   NULL,
    [SalariedFlag]                         BIT             NULL,
    [Gender]                               char (1)       NULL,
    [PayFrequency]                         smallint         NULL,
    [BaseRate]                             numeric(14,4)           NULL,
    [VacationHours]                        SMALLINT        NULL,
    [SickLeaveHours]                       SMALLINT        NULL,
    [CurrentFlag]                          BIT             NOT NULL,
    [SalesPersonFlag]                      BIT             NOT NULL,
    [DepartmentName]                       VARCHAR (50)   NULL,
    [StartDate]                            DATE            NULL,
    [EndDate]                              DATE            NULL,
    [Status]                               VARCHAR (50)   NULL,
    [EmployeePhoto]                        varbinary(4000) NULL
);
GO

ALTER TABLE [dbo].[DimEmployee]
    ADD CONSTRAINT [FK_DimEmployee_DimSalesTerritory] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [dbo].[DimSalesTerritory] ([SalesTerritoryKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimEmployee]
    ADD CONSTRAINT [PK_DimEmployee_EmployeeKey] PRIMARY KEY NONCLUSTERED ([EmployeeKey] ASC) NOT ENFORCED;
GO

