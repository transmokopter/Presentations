CREATE TABLE [dbo].[DimAccount] (
    [AccountKey]                    INT            NOT NULL,
    [ParentAccountKey]              INT            NULL,
    [AccountCodeAlternateKey]       INT            NULL,
    [ParentAccountCodeAlternateKey] INT            NULL,
    [AccountDescription]            VARCHAR (50)  NULL,
    [AccountType]                   VARCHAR (50)  NULL,
    [Operator]                      VARCHAR (50)  NULL,
    [CustomMembers]                 VARCHAR (300) NULL,
    [ValueType]                     VARCHAR (50)  NULL,
    [CustomMemberOptions]           VARCHAR (200) NULL
);
GO

ALTER TABLE [dbo].[DimAccount]
    ADD CONSTRAINT [PK_DimAccount] PRIMARY KEY NONCLUSTERED ([AccountKey] ASC) NOT ENFORCED;
GO
