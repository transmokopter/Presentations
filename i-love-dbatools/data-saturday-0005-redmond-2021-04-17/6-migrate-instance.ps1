
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

$startDbaMigrationSplat = @{
    Source = "localhost,1401"
    Destination = "localhost,1402"
    SourceSqlCredential = $cred 
    DestinationSqlCredential = $cred 
    BackupRestore = $true 
    SharedPath = "\\TSQLWS1\sqlmigration"
}

Start-DbaMigration @startDbaMigrationSplat -whatif

#Skipping full migration.
Copy-DbaLogin -Source "localhost,1401" -Destination "localhost,1402" -SourceSqlCredential $cred -DestinationSqlCredential $cred 
Copy-DbaAgentJob -Source "localhost,1401" -SourceSqlCredential $cred -Destination "localhost,1402" -DestinationSqlCredential $cred -DisableOnDestination -Force


#Create new database on target instance, and add a metadatatable to it
$createDatabaseSql = "CREATE DATABASE LogShippingMetadata"
$createTableSql = "CREATE TABLE LogShippingWatermarks (databasename nvarchar(128) CONSTRAINT PK_LogShippingWaterMarks PRIMARY KEY CLUSTERED, LastFull nvarchar(max), LastLSN bigint)"
$insertLogshippingWatermarksSql = "INSERT LogShippingWatermarks (databasename, LastFull, LastLsn) VALUES('DBA', NULL, 0)"

Invoke-DbaQuery -SqlInstance "localhost,1402" -SqlCredential $cred -Database master -Query $createDatabaseSql;
Invoke-DbaQuery -SqlInstance "localhost,1402" -SqlCredential $cred -database LogShippingMetadata -query $createTableSql
Invoke-DbaQuery -SqlInstance "localhost,1402" -SqlCredential $cred -database LogShippingMetadata -query $insertLogshippingWatermarksSql

# Find last full backup. Get-DbaBackupHistory fullname property is a string array. We will be using single backup files, 
#so first item is ours to get 
$backuppath=(Get-DbaDbBackupHistory -SqlInstance "localhost,1401" -SqlCredential $cred -Database DBA -LastFull).FullName[0]
$backuppath 
Restore-DbaDatabase -SqlInstance "localhost,1402" -SqlCredential $cred -Path $backuppath -WithReplace -NoRecovery 

$updateWatermarksSql = "UPDATE LogShippingWatermarks SET LastFull = @LastFull,lastlsn=0 WHERE databasename = @DBName"
$invokeDbaQuerySplat = @{
    SqlInstance = "localhost,1402"
    SqlCredential = $cred 
    Database = "LogShippingMetadata"
}
Invoke-DbaQuery @invokeDbaQuerySplat -Query $updateWatermarksSql -SqlParameters  @{ DBName="DBA"; LastFull = $backuppath}

#Now start the log shipping, we have the full backup restored and DB is in norecovery mode
$getLastLsnQuery = "SELECT LastLsn FROM LogShippingWatermarks WHERE databasename=@dbname"
$lastlsn = (Invoke-DbaQuery @invokeDbaQuerySplat -Query $getLastLsnQuery -SqlParameters @{dbname = "DBA"}).Item("LastLsn")
$lastlsn
foreach( $logbackup in Get-DbaDbBackupHistory -SqlInstance "localhost,1401" -SqlCredential $cred -database DBA -Type Log -lastlsn $lastlsn | Sort-Object -Property Start){
    [int64]$lsn=$LogBackup.LastLSN
    $lsn 
    $backuppath = $LogBackup.Path[0] 
    $backuppath 
    Restore-DbaDatabase -SqlInstance "localhost,1402" -SqlCredential $cred -Path $backuppath -databasename "DBA" -withreplace -NoRecovery -Continue 
    $updateLastLsnSql = "UPDATE LogShippingWaterMarks SET LastLsn=@LastLsn WHERE databasename=@dbname"
    Invoke-DbaQuery -SqlInstance "localhost,1402" -SqlCredential $cred -Database LogShippingMetadata -Query $updateLastLsnSql -SqlParameters @{LastLsn=$lsn;DBName="DBA"}
}

Invoke-DbaQuery -SqlInstance "localhost,1402" -SqlCredential $cred -Database LogShippingMetadata -Query "SELECT * FROM LogShippingWaterMarks"

#Have a look at storage container
#Have a look at SSMS
#Run logshipping sequence again
