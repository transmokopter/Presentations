CREATE TABLE [dbo].[FactSurveyResponse] (
    [SurveyResponseKey]             INT            NOT NULL,
    [DateKey]                       INT           NOT NULL,
    [CustomerKey]                   INT           NOT NULL,
    [ProductCategoryKey]            INT           NOT NULL,
    [EnglishProductCategoryName]    VARCHAR (50) NOT NULL,
    [ProductSubcategoryKey]         INT           NOT NULL,
    [EnglishProductSubcategoryName] VARCHAR (50) NOT NULL,
    [Date]                          datetime2(6)      NULL
);
GO

ALTER TABLE [dbo].[FactSurveyResponse]
    ADD CONSTRAINT [FK_FactSurveyResponse_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactSurveyResponse]
    ADD CONSTRAINT [FK_FactSurveyResponse_DateKey] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactSurveyResponse]
    ADD CONSTRAINT [PK_FactSurveyResponse_SurveyResponseKey] PRIMARY KEY NONCLUSTERED ([SurveyResponseKey] ASC) NOT ENFORCED;
GO

