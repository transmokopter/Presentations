CREATE TABLE [dbo].[FactCallCenter] (
    [FactCallCenterID]    INT            NOT NULL,
    [DateKey]             INT           NOT NULL,
    [WageType]            VARCHAR (15) NOT NULL,
    [Shift]               VARCHAR (20) NOT NULL,
    [LevelOneOperators]   SMALLINT      NOT NULL,
    [LevelTwoOperators]   SMALLINT      NOT NULL,
    [TotalOperators]      SMALLINT      NOT NULL,
    [Calls]               INT           NOT NULL,
    [AutomaticResponses]  INT           NOT NULL,
    [Orders]              INT           NOT NULL,
    [IssuesRaised]        SMALLINT      NOT NULL,
    [AverageTimePerIssue] SMALLINT      NOT NULL,
    [ServiceGrade]        FLOAT    NOT NULL,
    [Date]                datetime2(6)      NULL
);
GO

ALTER TABLE [dbo].[FactCallCenter]
    ADD CONSTRAINT [FK_FactCallCenter_DimDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactCallCenter]
    ADD CONSTRAINT [PK_FactCallCenter_FactCallCenterID] PRIMARY KEY NONCLUSTERED ([FactCallCenterID] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactCallCenter]
    ADD CONSTRAINT [AK_FactCallCenter_DateKey_Shift] UNIQUE NONCLUSTERED ([DateKey] ASC, [Shift] ASC) NOT ENFORCED;
GO

