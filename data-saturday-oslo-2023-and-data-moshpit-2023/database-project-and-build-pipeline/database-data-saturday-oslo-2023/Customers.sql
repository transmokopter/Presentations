CREATE TABLE [dbo].[Customers]
(
	[CustomerId] INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED,
	CustomerName nvarchar(255) NOT NULL
);

GO

CREATE INDEX ix_Customers_CustomerName ON dbo.Customers(CustomerName)
GO