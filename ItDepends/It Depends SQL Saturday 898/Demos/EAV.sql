DROP DATABASE IF EXISTS EAV;
GO
CREATE DATABASE EAV;
GO
USE EAV;
GO
CREATE TABLE dbo.Customer(CustomerID INT CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED);
INSERT dbo.Customer(CustomerID)
SELECT CustomerKey FROM AdventureWorksDW2014.dbo.DimCustomer; 

CREATE TABLE AttributeValues (CustomerID int, Attribute VARCHAR(100),AttributeValue VARCHAR(100));
CREATE INDEX ix_AttributeValue ON AttributeValues(Attribute,AttributeValue)
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'GeographyKey', cast(GeographyKey as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'CustomerAlternateKey', cast(CustomerAlternateKey as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'Title', cast(Title as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'FirstName', cast(FirstName as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'MiddleName', cast(MiddleName as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'LastName', cast(LastName as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'NameStyle', cast(NameStyle as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'BirthDate', cast(BirthDate as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'MaritalStatus', cast(MaritalStatus as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'Suffix', cast(Suffix as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'Gender', cast(Gender as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'EmailAddress', cast(EmailAddress as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'YearlyIncome', cast(YearlyIncome as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'TotalChildren', cast(TotalChildren as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'NumberChildrenAtHome', cast(NumberChildrenAtHome as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'EnglishEducation', cast(EnglishEducation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'SpanishEducation', cast(SpanishEducation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'FrenchEducation', cast(FrenchEducation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'EnglishOccupation', cast(EnglishOccupation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'SpanishOccupation', cast(SpanishOccupation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'FrenchOccupation', cast(FrenchOccupation as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'HouseOwnerFlag', cast(HouseOwnerFlag as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'NumberCarsOwned', cast(NumberCarsOwned as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'AddressLine1', cast(AddressLine1 as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'AddressLine2', cast(AddressLine2 as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'Phone', cast(Phone as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'DateFirstPurchase', cast(DateFirstPurchase as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
  INSERT AttributeValues (CustomerID, Attribute, AttributeValue)  SELECT c.CustomerKey,'CommuteDistance', cast(CommuteDistance as varchar(100))  FROM adventureworksdw2014.dbo.dimcustomer c  
GO

CREATE VIEW dbo.CustomerAttributes 
AS 
SELECT 
	c.CustomerID,
	MAX(case when Attribute='AddressLine1' THEN AttributeValue ELSE NULL END) as AddressLine1,
	MAX(case when Attribute='AddressLine2' THEN AttributeValue ELSE NULL END) as AddressLine2,
	MAX(case when Attribute='BirthDate' THEN AttributeValue ELSE NULL END) as BirthDate,
	MAX(case when Attribute='CommuteDistance' THEN AttributeValue ELSE NULL END) as CommuteDistance,
	MAX(case when Attribute='CustomerAlternateKey' THEN AttributeValue ELSE NULL END) as CustomerAlternateKey,
	MAX(case when Attribute='DateFirstPurchase' THEN AttributeValue ELSE NULL END) as DateFirstPurchase,
	MAX(case when Attribute='EmailAddress' THEN AttributeValue ELSE NULL END) as EmailAddress,
	MAX(case when Attribute='EnglishEducation' THEN AttributeValue ELSE NULL END) as EnglishEducation,
	MAX(case when Attribute='EnglishOccupation' THEN AttributeValue ELSE NULL END) as EnglishOccupation,
	MAX(case when Attribute='FirstName' THEN AttributeValue ELSE NULL END) as FirstName,
	MAX(case when Attribute='FrenchEducation' THEN AttributeValue ELSE NULL END) as FrenchEducation,
	MAX(case when Attribute='FrenchOccupation' THEN AttributeValue ELSE NULL END) as FrenchOccupation,
	MAX(case when Attribute='Gender' THEN AttributeValue ELSE NULL END) as Gender,
	MAX(case when Attribute='GeographyKey' THEN AttributeValue ELSE NULL END) as GeographyKey,
	MAX(case when Attribute='HouseOwnerFlag' THEN AttributeValue ELSE NULL END) as HouseOwnerFlag,
	MAX(case when Attribute='LastName' THEN AttributeValue ELSE NULL END) as LastName,
	MAX(case when Attribute='MaritalStatus' THEN AttributeValue ELSE NULL END) as MaritalStatus,
	MAX(case when Attribute='MiddleName' THEN AttributeValue ELSE NULL END) as MiddleName,
	MAX(case when Attribute='NameStyle' THEN AttributeValue ELSE NULL END) as NameStyle,
	MAX(case when Attribute='NumberCarsOwned' THEN AttributeValue ELSE NULL END) as NumberCarsOwned,
	MAX(case when Attribute='NumberChildrenAtHome' THEN AttributeValue ELSE NULL END) as NumberChildrenAtHome,
	MAX(case when Attribute='Phone' THEN AttributeValue ELSE NULL END) as Phone,
	MAX(case when Attribute='SpanishEducation' THEN AttributeValue ELSE NULL END) as SpanishEducation,
	MAX(case when Attribute='SpanishOccupation' THEN AttributeValue ELSE NULL END) as SpanishOccupation,
	MAX(case when Attribute='Suffix' THEN AttributeValue ELSE NULL END) as Suffix,
	MAX(case when Attribute='Title' THEN AttributeValue ELSE NULL END) as Title,
	MAX(case when Attribute='TotalChildren' THEN AttributeValue ELSE NULL END) as TotalChildren,
	MAX(case when Attribute='YearlyIncome' THEN AttributeValue ELSE NULL END) as YearlyIncome
FROM dbo.AttributeValues c
GROUP BY CustomerID;
GO

SELECT * FROM dbo.CustomerAttributes;

--OK
SELECT * FROM dbo.CustomerAttributes WHERE CustomerID=12190;

--Not really OK. This predicate will be evaluated as a HAVING clause, since it's filtering the result of a grouped aggregate query. Meaning EVERYTHING must be aggregated prior to filtering.
SELECT * FROM dbo.CustomerAttributes WHERE CustomerAlternateKey='AW00012190';

GO








--Better
CREATE FUNCTION dbo.GetCustomerIDsFORAttributeValue(@attribute varchar(100),@attributeValue varchar(100))
RETURNS TABLE AS
RETURN 
 SELECT CustomerID FROM AttributeValues WHERE Attribute=@attribute AND attributevalue=@attributevalue;
GO

SELECT ca.* FROM dbo.CustomerAttributes ca
INNER JOIN dbo.GetCustomerIDsFORAttributeValue('CustomerAlternateKey','AW00012190') a
ON ca.customerid=a.customerid;

GO

