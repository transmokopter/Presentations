CREATE TABLE [dbo].[DatabaseLog] (
    [DatabaseLogID] INT             NOT NULL,
    [PostTime]      datetime2(6)       NOT NULL,
    [DatabaseUser]  varchar(255)      NOT NULL,
    [Event]         varchar(255)      NOT NULL,
    [Schema]        varchar(255)      NULL,
    [Object]        varchar(255)      NULL,
    [TSQL]          varchar (4000) NOT NULL,
    [XmlEvent]      varchar(8000)            NOT NULL
);
GO

ALTER TABLE [dbo].[DatabaseLog]
    ADD CONSTRAINT [PK_DatabaseLog_DatabaseLogID] PRIMARY KEY NONCLUSTERED ([DatabaseLogID] ASC) NOT ENFORCED ;
GO

