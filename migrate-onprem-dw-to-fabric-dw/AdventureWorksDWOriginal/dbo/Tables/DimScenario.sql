CREATE TABLE [dbo].[DimScenario] (
    [ScenarioKey]  INT           IDENTITY (1, 1) NOT NULL,
    [ScenarioName] NVARCHAR (50) NULL
);
GO

ALTER TABLE [dbo].[DimScenario]
    ADD CONSTRAINT [PK_DimScenario] PRIMARY KEY CLUSTERED ([ScenarioKey] ASC);
GO

