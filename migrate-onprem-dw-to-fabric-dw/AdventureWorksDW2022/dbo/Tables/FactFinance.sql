CREATE TABLE [dbo].[FactFinance] (
    [FinanceKey]         INT         NOT NULL,
    [DateKey]            INT        NOT NULL,
    [OrganizationKey]    INT        NOT NULL,
    [DepartmentGroupKey] INT        NOT NULL,
    [ScenarioKey]        INT        NOT NULL,
    [AccountKey]         INT        NOT NULL,
    [Amount]             FLOAT NOT NULL,
    [Date]               datetime2(6)   NULL
);
GO

ALTER TABLE [dbo].[FactFinance]
    ADD CONSTRAINT [FK_FactFinance_DimDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactFinance]
    ADD CONSTRAINT [FK_FactFinance_DimScenario] FOREIGN KEY ([ScenarioKey]) REFERENCES [dbo].[DimScenario] ([ScenarioKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactFinance]
    ADD CONSTRAINT [FK_FactFinance_DimOrganization] FOREIGN KEY ([OrganizationKey]) REFERENCES [dbo].[DimOrganization] ([OrganizationKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactFinance]
    ADD CONSTRAINT [FK_FactFinance_DimAccount] FOREIGN KEY ([AccountKey]) REFERENCES [dbo].[DimAccount] ([AccountKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactFinance]
    ADD CONSTRAINT [FK_FactFinance_DimDepartmentGroup] FOREIGN KEY ([DepartmentGroupKey]) REFERENCES [dbo].[DimDepartmentGroup] ([DepartmentGroupKey]) NOT ENFORCED ;
GO

