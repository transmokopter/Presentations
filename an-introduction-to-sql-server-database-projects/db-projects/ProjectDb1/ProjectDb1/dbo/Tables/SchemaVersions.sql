CREATE TABLE [dbo].[SchemaVersions] (
    [SchemaVersion] VARCHAR (30) NOT NULL,
    [Applied]       DATETIME     NOT NULL,
    CONSTRAINT [pk_SchemaVersion] PRIMARY KEY CLUSTERED ([SchemaVersion] ASC)
);

