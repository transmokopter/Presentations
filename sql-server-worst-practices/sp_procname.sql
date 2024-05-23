USE SqlServerWorstPractices
GO
CREATE OR ALTER PROC dbo.sp_help @ObjectName NVARCHAR(100)
AS
SELECT SUBSTRING(@ObjectName,value,1) AS the_char
FROM generate_series(1,LEN(@ObjectName),1)
GO
-- Let's try our amazing procedure
EXEC sp_help 'hi there rockstar'

--Uhuh?! Ok, schema qualify
EXEC dbo.sp_help 'hi there rockstar'

--Wtaf! Let's three-part-name this sucker then!
EXEC SqlServerWorstPractices.dbo.sp_help 'hi there rockstar'

--Now I'm scared. Let's rename it. Maybe this grumpy DBA was right for once
EXEC sp_rename 'sp_help','spHelp'
--Oh yes. It's there. I promise.
SELECT * FROM sys.procedures 



DROP PROC dbo.sp_help
GO
CREATE OR ALTER PROC dbo.spHelp @ObjectName NVARCHAR(100)
AS
SELECT SUBSTRING(@ObjectName,value,1) AS the_char
FROM generate_series(1,LEN(@ObjectName),1)
GO
EXEC spHelp 'Hi there rockstar'

-- This is funny
EXEC sp_rename 'spHelp','sp_help'
GO
