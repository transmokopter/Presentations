USE master;  

CREATE LOGIN aoag_login WITH PASSWORD = 'Pa$$w0rd';
CREATE USER aoag_user FOR LOGIN aoag_login;

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa55w.rd';  

CREATE CERTIFICATE db1cert
	AUTHORIZATION aoag_user
    FROM FILE = '/var/opt/mssql/data/db1cert.cer'
    WITH PRIVATE KEY (
           FILE = '/var/opt/mssql/data/db1cert.pvk',
           DECRYPTION BY PASSWORD = 'Pa55w.rd'
        );
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

GRANT CONNECT ON ENDPOINT::Endpoint_Mirroring TO [aoag_login];
IF (SELECT state FROM sys.endpoints WHERE name = N'Endpoint_Mirroring') <> 0
BEGIN
	ALTER ENDPOINT [Endpoint_Mirroring] STATE = STARTED
END


GO


IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO


GRANT ALTER ANY AVAILABILITY GROUP TO aoag_login;
ALTER AVAILABILITY GROUP [agsandbox] JOIN WITH (CLUSTER_TYPE = NONE);

GO

ALTER AVAILABILITY GROUP [agsandbox] GRANT CREATE ANY DATABASE;

