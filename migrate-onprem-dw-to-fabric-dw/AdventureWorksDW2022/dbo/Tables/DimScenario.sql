CREATE TABLE [dbo].[DimScenario] (
    [ScenarioKey]  INT            NOT NULL,
    [ScenarioName] VARCHAR (50) NULL
);
GO

ALTER TABLE [dbo].[DimScenario]
    ADD CONSTRAINT [PK_DimScenario] PRIMARY KEY NONCLUSTERED ([ScenarioKey] ASC) NOT ENFORCED;
GO

