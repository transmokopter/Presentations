CREATE TABLE [dbo].[DimEmployee] (
    [EmployeeKey]                          INT             IDENTITY (1, 1) NOT NULL,
    [ParentEmployeeKey]                    INT             NULL,
    [EmployeeNationalIDAlternateKey]       NVARCHAR (15)   NULL,
    [ParentEmployeeNationalIDAlternateKey] NVARCHAR (15)   NULL,
    [SalesTerritoryKey]                    INT             NULL,
    [FirstName]                            NVARCHAR (50)   NOT NULL,
    [LastName]                             NVARCHAR (50)   NOT NULL,
    [MiddleName]                           NVARCHAR (50)   NULL,
    [NameStyle]                            BIT             NOT NULL,
    [Title]                                NVARCHAR (50)   NULL,
    [HireDate]                             DATE            NULL,
    [BirthDate]                            DATE            NULL,
    [LoginID]                              NVARCHAR (256)  NULL,
    [EmailAddress]                         NVARCHAR (50)   NULL,
    [Phone]                                NVARCHAR (25)   NULL,
    [MaritalStatus]                        NCHAR (1)       NULL,
    [EmergencyContactName]                 NVARCHAR (50)   NULL,
    [EmergencyContactPhone]                NVARCHAR (25)   NULL,
    [SalariedFlag]                         BIT             NULL,
    [Gender]                               NCHAR (1)       NULL,
    [PayFrequency]                         TINYINT         NULL,
    [BaseRate]                             MONEY           NULL,
    [VacationHours]                        SMALLINT        NULL,
    [SickLeaveHours]                       SMALLINT        NULL,
    [CurrentFlag]                          BIT             NOT NULL,
    [SalesPersonFlag]                      BIT             NOT NULL,
    [DepartmentName]                       NVARCHAR (50)   NULL,
    [StartDate]                            DATE            NULL,
    [EndDate]                              DATE            NULL,
    [Status]                               NVARCHAR (50)   NULL,
    [EmployeePhoto]                        VARBINARY (MAX) NULL
);
GO

ALTER TABLE [dbo].[DimEmployee]
    ADD CONSTRAINT [FK_DimEmployee_DimSalesTerritory] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [dbo].[DimSalesTerritory] ([SalesTerritoryKey]);
GO

ALTER TABLE [dbo].[DimEmployee]
    ADD CONSTRAINT [FK_DimEmployee_DimEmployee] FOREIGN KEY ([ParentEmployeeKey]) REFERENCES [dbo].[DimEmployee] ([EmployeeKey]);
GO

ALTER TABLE [dbo].[DimEmployee]
    ADD CONSTRAINT [PK_DimEmployee_EmployeeKey] PRIMARY KEY CLUSTERED ([EmployeeKey] ASC);
GO
