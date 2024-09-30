CREATE TABLE [dbo].[DimDate] (
    [DateKey]              INT           NOT NULL,
    [FullDateAlternateKey] DATE          NOT NULL,
    [DayNumberOfWeek]      smallint       NOT NULL,
    [EnglishDayNameOfWeek] VARCHAR (10) NOT NULL,
    [SpanishDayNameOfWeek] VARCHAR (10) NOT NULL,
    [FrenchDayNameOfWeek]  VARCHAR (10) NOT NULL,
    [DayNumberOfMonth]     smallint       NOT NULL,
    [DayNumberOfYear]      SMALLINT      NOT NULL,
    [WeekNumberOfYear]     smallint       NOT NULL,
    [EnglishMonthName]     VARCHAR (10) NOT NULL,
    [SpanishMonthName]     VARCHAR (10) NOT NULL,
    [FrenchMonthName]      VARCHAR (10) NOT NULL,
    [MonthNumberOfYear]    smallint       NOT NULL,
    [CalendarQuarter]      smallint       NOT NULL,
    [CalendarYear]         SMALLINT      NOT NULL,
    [CalendarSemester]     smallint       NOT NULL,
    [FiscalQuarter]        smallint       NOT NULL,
    [FiscalYear]           SMALLINT      NOT NULL,
    [FiscalSemester]       smallint       NOT NULL
);
GO


ALTER TABLE [dbo].[DimDate]
    ADD CONSTRAINT [PK_DimDate_DateKey] PRIMARY KEY NONCLUSTERED ([DateKey] ASC) NOT ENFORCED;
GO

