--DROP TABLE dbo.__MigrationHistory
--DROP TABLE people;
TRUNCATE TABLE people;
--Alternative solution

GO

USE [rbar]
GO

/****** Object:  Table [dbo].[People]    Script Date: 2019-10-23 16:22:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS(SELECT * FROM sys.types WHERE name='PeopleType')
BEGIN
DECLARE @s NVARCHAR(MAX)=N'
CREATE TYPE dbo.PeopleType AS TABLE(
	[ID] [int] NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[Gender] [nvarchar](max) NULL,
	[Age] [int] NOT NULL,
	[Address] [nvarchar](max) NULL,
	[ZipCode] [nvarchar](max) NULL,
	[Location] [nvarchar](max) NULL,
	[BirthDate] [datetime] NOT NULL,
	[PersonNummer] [nvarchar](max) NULL)
';
EXECUTE sp_executesql @statement=@s;
end
GO

CREATE OR ALTER PROC dbo.InsertLotsOfPeople(@people AS dbo.PeopleType readonly)
AS
BEGIN
	INSERT dbo.People (id,firstname,lastname,gender,age,address,zipcode,location,birthdate,personnummer)
	SELECT id,firstname,lastname,gender,age,address,zipcode,location,birthdate,personnummer FROM @people;
END
