CREATE DATABASE sandbox;
BACKUP DATABASE sandbox TO DISK='nul';
--blablabla some code to create an availability group and backup keys and
USE master;  
CREATE LOGIN aoag_login WITH PASSWORD = 'Pa$$w0rd';
CREATE USER aoag_user FOR LOGIN aoag_login;
GRANT ALTER ANY AVAILABILITY GROUP TO aoag_login;

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa55w.rd';  

CREATE CERTIFICATE db1cert
   AUTHORIZATION aoag_user
   WITH SUBJECT = 'db1cert';
GO  
CREATE ENDPOINT Endpoint_Mirroring  
   STATE = STARTED  
   AS TCP (  
      LISTENER_PORT=5022
      , LISTENER_IP = ALL  
   )   
   FOR DATABASE_MIRRORING (   
      AUTHENTICATION = CERTIFICATE db1cert  
      , ENCRYPTION = REQUIRED ALGORITHM AES  
      , ROLE = PARTNER  
   );  
GO  

GRANT CONNECT ON ENDPOINT::Endpoint_Mirroring TO aoag_login;
GO
IF (SELECT state FROM sys.endpoints WHERE name = N'Endpoint_Mirroring') <> 0
BEGIN
	ALTER ENDPOINT [Endpoint_Mirroring] STATE = STARTED
END

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END
GO


CREATE AVAILABILITY GROUP [agsandbox]
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE,
CLUSTER_TYPE = NONE,
REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT = 0)
FOR DATABASE [sandbox]
REPLICA ON 
	N'db2' WITH (ENDPOINT_URL = N'TCP://db2:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL)),
	N'db1' WITH (ENDPOINT_URL = N'TCP://db1:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL));
GO


BACKUP CERTIFICATE db1cert
   TO FILE = '/var/opt/mssql/data/db1cert.cer'
   WITH PRIVATE KEY (
           FILE = '/var/opt/mssql/data/db1cert.pvk',
           ENCRYPTION BY PASSWORD = 'Pa55w.rd'
        );