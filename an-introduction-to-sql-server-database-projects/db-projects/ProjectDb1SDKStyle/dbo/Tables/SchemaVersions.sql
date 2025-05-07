CREATE TABLE [dbo].[SchemaVersions] (
    [SchemaVersion] VARCHAR (30) NOT NULL,
    [Applied]       DATETIME     NOT NULL
);
GO

ALTER TABLE [dbo].[SchemaVersions]
    ADD CONSTRAINT [pk_SchemaVersion] PRIMARY KEY CLUSTERED ([SchemaVersion] ASC);
GO

