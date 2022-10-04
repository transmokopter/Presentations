USE master;
ALTER DATABASE AdventureWorks2019 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE AdventureWorks2019 FROM DISK=N'/var/opt/mssql/data/AdventureWorks2019.bak' WITH REPLACE;
GO
USE AdventureWorks2019;
--Prepare with some data skew
DECLARE @t TABLE(id INT);
INSERT INTO Person.BusinessEntity
(
    ModifiedDate
)
OUTPUT inserted.BusinessEntityID INTO @t
SELECT current_timestamp FROM person.person WHERE lastname='Diaz'
DECLARE @minId INT;
SELECT @minId = MIN(id) FROM @t;
INSERT INTO Person.Person
(
	BusinessEntityID,
    PersonType,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    EmailPromotion,
    AdditionalContactInfo,
    Demographics,
    ModifiedDate
)
SELECT 
	ROW_NUMBER() OVER(ORDER BY (SELECT NULL))+@minId-1,
	PersonType,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    EmailPromotion,
    AdditionalContactInfo,
    Demographics,
    ModifiedDate
FROM person.Person AS P 
WHERE lastname='Diaz'
GO 3
USE AdventureWorks2019;


SELECT 
	i.name,
	c.name AS columnname,
	ic.is_included_column,
	ic.index_column_id
FROM sys.index_columns AS IC
	INNER JOIN sys.columns AS C
	ON c.object_id = ic.object_id
		AND c.column_id = ic.column_id
	INNER JOIN sys.indexes AS I
	ON ic.index_id = i.index_id
		AND ic.object_id = i.object_id
WHERE i.object_id = OBJECT_ID(N'Person.Person') AND i.name = N'IX_Person_LastName_FirstName_MiddleName'
ORDER BY ic.index_column_id;

--Covering index query
SELECT * FROM Person.Person
	WHERE FirstName = N'Ken' AND LastName = N'Sánchez';
--Notice the key lookup

--Key column with high selectivity
SET STATISTICS IO ON;
SELECT * FROM Person.Person 
	WHERE LastName = 'diaz';
--compare with clustered index scan
SELECT * FROM Person.Person;

--Let's refresh statistics to cater for the newly inserted rows
UPDATE STATISTICS Person.Person WITH FULLSCAN;
SELECT * FROM Person.Person 
	WHERE LastName = 'diaz';
--How about a filtered index for Diaz?
CREATE INDEX ix_Person_LastName_FirstName_MiddleName_FILTER_LastNameISDiaz
ON Person.Person (LastName, FirstName,MiddleName) WHERE LastName=N'Diaz';
SELECT * FROM Person.Person 
	WHERE LastName = 'diaz';

--No, the key lookup is still necessary.
--Let's only include index columns
SELECT Lastname, FirstName, Middlename FROM Person.Person 
	WHERE LastName = 'diaz';
--Oh, clustering key is in leaf level of non-clustered index, so even with that included it should be a covering index
SELECT Lastname, FirstName, Middlename, BusinessEntityID
FROM Person.Person 
	WHERE LastName = 'diaz';



--Non-key column, high selectivity
SELECT * FROM Person.Person AS P
	WHERE FirstName = N'Ken';

--Non-key column, low selectivity
SELECT * FROM Person.Person AS P
	WHERE FirstName LIKE N'R%';


SELECT lastname,firstname,middlename,P.BusinessEntityID 
FROM Person.Person AS P WHERE PersonType=N'EM' AND LastName = 'Diaz';
--Let's try single column index on persontype

CREATE INDEX ix_Person_PersonType ON Person.Person(PersonType);

SELECT lastname,firstname,middlename,P.BusinessEntityID 
FROM Person.Person AS P WHERE PersonType=N'EM' AND LastName = 'Diaz';

CREATE INDEX ix_Person_LastName_FirstName_MiddleName ON Person.Person
(LastName, FirstName, MiddleName, PersonType)
WITH DROP_EXISTING;

SELECT lastname,firstname,middlename,P.BusinessEntityID 
FROM Person.Person AS P WHERE PersonType=N'EM' AND LastName = 'Diaz';

--Specialised index with PersonType before Lastname would be more effective for THIS specific query. 
--But for other persontypes and other lastnames, it wouldn't have the same effect. This is Good Enough (TM)

--Columnstore index on the same table, let's see what happens. Probably not much, as it's such small table, but let's examine

CREATE NONCLUSTERED COLUMNSTORE INDEX ncci_Person ON Person.Person(
[BusinessEntityID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailPromotion], 
[AdditionalContactInfo], [Demographics], [rowguid], [ModifiedDate]
)
--Nope, XML-columns can't be in Columnstore index. Geography and Geometry can't either
CREATE NONCLUSTERED COLUMNSTORE INDEX ncci_Person ON Person.Person(
[BusinessEntityID], [PersonType], [NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailPromotion], 
[rowguid], [ModifiedDate]
)
SELECT lastname,firstname,middlename,P.BusinessEntityID 
FROM Person.Person AS P WHERE PersonType=N'EM' AND LastName = 'Sánchez';

DROP INDEX ncci_person ON Person.Person;

GO



