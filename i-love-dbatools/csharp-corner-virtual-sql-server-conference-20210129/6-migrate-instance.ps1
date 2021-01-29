
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

$startDbaMigrationSplat = @{
    Source = "sql1"
    Destination = "sql2"
    SourceSqlCredential = $cred 
    DestinationSqlCredential = $cred 
    BackupRestore = $true 
    SharedPath = "\\TSQLWS1\sqlmigration"
}

Start-DbaMigration @startDbaMigrationSplat -whatif

#Skipping full migration.
Copy-DbaLogin -Source sql1 -Destination sql2 -SourceSqlCredential $cred -DestinationSqlCredential $cred 
Copy-DbaAgentJob -Source sql1 -SourceSqlCredential $cred -Destination sql2 -DestinationSqlCredential $cred -DisableOnDestination 


#Create new database on target instance, and add a metadatatable to it
$createDatabaseSql = "CREATE DATABASE LogShippingMetadata"
$createTableSql = "CREATE TABLE LogShippingWatermarks (databasename nvarchar(128) CONSTRAINT PK_LogShippingWaterMarks PRIMARY KEY CLUSTERED, LastFull nvarchar(max), LastLSN bigint)"
$insertLogshippingWatermarksSql = "INSERT LogShippingWatermarks (databasename, LastFull, LastLsn) VALUES('DBA', NULL, 0)"

Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database master -Query $createDatabaseSql;
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -database LogShippingMetadata -query $createTableSql
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -database LogShippingMetadata -query $insertLogshippingWatermarksSql

# Find last full backup. Get-DbaBackupHistory fullname property is a string array. We will be using single backup files, 
#so first item is ours to get 
$backuppath=(Get-DbaDbBackupHistory -SqlInstance sql1 -SqlCredential $cred -Database DBA -LastFull).FullName[0]
$backuppath 
Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $backuppath -WithReplace -NoRecovery 

$updateWatermarksSql = "UPDATE LogShippingWatermarks SET LastFull = @LastFull,lastlsn=0 WHERE databasename = @DBName"
$invokeDbaQuerySplat = @{
    SqlInstance = "sql2"
    SqlCredential = $cred 
    Database = "LogShippingMetadata"
}
Invoke-DbaQuery @invokeDbaQuerySplat -Query $updateWatermarksSql -SqlParameters  @{ DBName="DBA"; LastFull = $backuppath}

#Now start the log shipping, we have the full backup restored and DB is in norecovery mode
$getLastLsnQuery = "SELECT LastLsn FROM LogShippingWatermarks WHERE databasename=@dbname"
$lastlsn = (Invoke-DbaQuery @invokeDbaQuerySplat -Query $getLastLsnQuery -SqlParameters @{dbname = "DBA"}).Item("LastLsn")
$lastlsn
foreach( $logbackup in Get-DbaDbBackupHistory -SqlInstance sql1 -SqlCredential $cred -database DBA -Type Log -lastlsn $lastlsn | Sort-Object -Property Start){
    [int64]$lsn=$LogBackup.LastLSN
    $lsn 
    $backuppath = $LogBackup.Path[0] 
    $backuppath 
    Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $backuppath -databasename "DBA" -withreplace -NoRecovery -Continue 
    $updateLastLsnSql = "UPDATE LogShippingWaterMarks SET LastLsn=@LastLsn WHERE databasename=@dbname"
    Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database LogShippingMetadata -Query $updateLastLsnSql -SqlParameters @{LastLsn=$lsn;DBName="DBA"}
}

Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database LogShippingMetadata -Query "SELECT * FROM LogShippingWaterMarks"

#Lets run some more transaction log backups
$blobStorageURL="https://transmokopterpsdemo.blob.core.windows.net/backups"
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"

