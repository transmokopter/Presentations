SET XACT_ABORT ON;
GO
-- Initiatialize empty database
IF DB_ID('MigrationDb') IS NULL
BEGIN
	CREATE DATABASE MigrationDb;
END 
GO

USE MigrationDb
IF NOT EXISTS( SELECT * FROM sys.tables WHERE name='SchemaVersions' )
BEGIN
	CREATE TABLE dbo.SchemaVersions(
		SchemaVersion VARCHAR(30) NOT NULL 
			CONSTRAINT pk_SchemaVersion PRIMARY KEY CLUSTERED,
		Applied DATETIME NOT NULL
	);
	INSERT dbo.SchemaVersions(SchemaVersion, Applied)
	VALUES('0.0.0',GETDATE())
END
GO

-- Version 1.0.0
DECLARE @version VARCHAR(30) = '1.0.0'
IF NOT EXISTS(
	SELECT * FROM dbo.SchemaVersions AS SV 
	WHERE SV.SchemaVersion = @version
)
BEGIN;
	BEGIN TRY;
		BEGIN TRAN;
		IF NOT EXISTS( SELECT * FROM sys.tables WHERE name='Customer' AND schema_id=SCHEMA_ID('dbo') )
			CREATE TABLE dbo.Customer(
				CustomerId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED,
				CustomerName NVARCHAR(100) NOT NULL
			);

		IF NOT EXISTS( SELECT * FROM sys.tables WHERE name='Product' AND schema_id=SCHEMA_ID('dbo') )
			CREATE TABLE dbo.Product(
				ProductId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Product PRIMARY KEY CLUSTERED,
				ProductName NVARCHAR(100) NOT NULL
			);

		IF NOT EXISTS( SELECT * FROM sys.tables WHERE name='CustomerOrder' AND schema_id=SCHEMA_ID('dbo') )
			CREATE TABLE dbo.CustomerOrder(
				OrderId INT IDENTITY(1,1) NOT NULL 
					CONSTRAINT PK_CustomerOrder PRIMARY KEY CLUSTERED,
				OrderDate DATETIME NOT NULL 
					CONSTRAINT DF_CustomerOrder_OrderDate_Now DEFAULT(GETDATE()),
				CustomerId INT NOT NULL 
					CONSTRAINT FK_CustomerOrder_Customer FOREIGN KEY REFERENCES dbo.Customer(CustomerId)
			);

		IF NOT EXISTS(
			SELECT * FROM sys.indexes i 
			WHERE i.object_id=OBJECT_ID('dbo.CustomerOrder')
				AND i.name='ix_CustomerOrder_CustomerId_OrderDate'
		)
			CREATE INDEX ix_CustomerOrder_CustomerId_OrderDate 
				ON dbo.CustomerOrder(CustomerId, OrderDate)
				WITH(DATA_COMPRESSION=PAGE, ONLINE=ON, MAXDOP=1, FILLFACTOR=85);
		
		IF NOT EXISTS(SELECT * FROM sys.tables WHERE name='CustomerOrderDetail' AND schema_id=SCHEMA_ID('dbo') )
			CREATE TABLE dbo.CustomerOrderDetail(
				OrderId INT NOT NULL 
					CONSTRAINT FK_CustomerOrderDetail_CustomerOrder FOREIGN KEY REFERENCES dbo.CustomerOrder(OrderId),
				OrderDetailLine TINYINT NOT NULL,
				ProductId INT NOT NULL
					CONSTRAINT FK_CustomerOrderDetail_Product FOREIGN KEY REFERENCES dbo.Product(ProductId),
				Quantity INT NOT NULL,
				ListPrice NUMERIC(8,2) NOT NULL,
				QuantityDiscount NUMERIC(4,4) NOT NULL,
				LoyaltyDiscount NUMERIC(4,4) NOT NULL
			);

		INSERT dbo.SchemaVersions(SchemaVersion, Applied)
		VALUES(@version,GETDATE());

		COMMIT;
	END TRY
	BEGIN CATCH;
		PRINT ERROR_MESSAGE();
		RAISERROR('Error occured during migrations, aborting upgrade script.',20,-1) WITH LOG
	END CATCH;
END
GO

-- Version 1.1.0
DECLARE @version VARCHAR(30) = '1.1.0'
IF NOT EXISTS(
	SELECT * FROM dbo.SchemaVersions AS SV 
	WHERE SV.SchemaVersion = @version
)
BEGIN;
	BEGIN TRY;
		BEGIN TRAN;
		
		IF EXISTS(
			SELECT * FROM sys.indexes i 
			WHERE i.object_id=OBJECT_ID('dbo.CustomerOrder')
				AND i.name='ix_CustomerOrder_CustomerId_OrderDate'
		)
			DROP INDEX ix_CustomerOrder_CustomerId_OrderDate ON dbo.CustomerOrder;
		
		IF NOT EXISTS(			SELECT * FROM sys.indexes i 
			WHERE i.object_id=OBJECT_ID('dbo.CustomerOrder')
				AND i.name='ix_CustomerOrder_OrderDate_CustomerId'
		)
			CREATE INDEX ix_CustomerOrder_OrderDate_CustomerId 
				ON dbo.CustomerOrder(OrderDate, CustomerId)
				WITH(DATA_COMPRESSION=PAGE, ONLINE=ON, MAXDOP=1, FILLFACTOR=85);

		INSERT dbo.SchemaVersions(SchemaVersion, Applied)
		VALUES(@version,GETDATE());

		COMMIT;
	END TRY
	BEGIN CATCH;
		PRINT ERROR_MESSAGE();
		RAISERROR('Error occured during migrations, aborting upgrade script.',20,-1) WITH LOG
	END CATCH;
END
GO

-- Version 1.2.0
DECLARE @version VARCHAR(30) = '1.2.0'
IF NOT EXISTS(
	SELECT * FROM dbo.SchemaVersions AS SV 
	WHERE SV.SchemaVersion = @version
)
BEGIN;
	BEGIN TRY;
		BEGIN TRAN;
		
		IF EXISTS(
			SELECT * FROM sys.indexes i 
			WHERE i.object_id=OBJECT_ID('dbo.CustomerOrder')
				AND i.name='ix_CustomerOrder_OrderDate_CustomerId'
		)
			DROP INDEX ix_CustomerOrder_OrderDate_CustomerId ON dbo.CustomerOrder;
		
		IF NOT EXISTS(			SELECT * FROM sys.indexes i 
			WHERE i.object_id=OBJECT_ID('dbo.CustomerOrder')
				AND i.name='ix_CustomerOrder_CustomerId_OrderDate'
		)
			CREATE INDEX ix_CustomerOrder_CustomerId_OrderDate 
				ON dbo.CustomerOrder(CustomerId, OrderDate)
				WITH(DATA_COMPRESSION=PAGE, ONLINE=ON, MAXDOP=1, FILLFACTOR=85);

		INSERT dbo.SchemaVersions(SchemaVersion, Applied)
		VALUES(@version,GETDATE());

		COMMIT;
	END TRY
	BEGIN CATCH;
		PRINT ERROR_MESSAGE();
		RAISERROR('Error occured during migrations, aborting upgrade script.',20,-1) WITH LOG
	END CATCH;
END
GO

SELECT * FROM dbo.SchemaVersions AS SV
