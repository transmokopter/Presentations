CREATE DATABASE DR
ON
PRIMARY ( -- or use FILEGROUP filegroup_name
  NAME = DR_data,
  FILENAME = '/var/opt/mssql/data/dr/DR.mdf'
) --, and repeat as required
LOG ON
(
  NAME = DR_log,
  FILENAME = '/var/opt/mssql/data/dr/DR.ldf'
)
GO

USE DR;
CREATE TABLE dbo.Customer(
	CustomerId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CustomerMasterdata PRIMARY KEY CLUSTERED,
	CustomerName NVARCHAR(200) NOT NULL,
	StreetAddress NVARCHAR(200) NOT NULL,
	ZipCode VARCHAR(20) NOT NULL,
	City NVARCHAR(200) NOT NULL,
	Country NVARCHAR(100) NOT NULL
);
GO
INSERT dbo.Customer(CustomerName, StreetAddress, ZipCode, City, Country)
VALUES 
(N'Transmokopter SQL AB', N'Badmintongatan 9', '74538', N'ENKÖPING', N'Sweden'),
(N'Microsoft',N'One Microsoft Way','55555',N'Seattle, WA', 'United States');

BACKUP DATABASE DR TO DISK='/var/opt/mssql/data/backups/dr.bak';
RESTORE VERIFYONLY FROM DISK='/var/opt/mssql/data/backups/dr.bak';

--Great, now our super important customer data is backed up.















-- Crash! Boom!! Bang!!!
RESTORE HEADERONLY FROM DISK='/var/opt/mssql/data/backups/dr.bak'

-- Oh, oh! We're in trouble!!

