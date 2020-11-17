
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

Start-DbaMigration -Source sql1 -Destination sql2 -SourceSqlCredential $cred -DestinationSqlCredential $cred -BackupRestore -SharedPath \\TSQLWS1\sqlmigration -whatif

#Skipping full migration.
Copy-DbaLogin -Source sql1 -Destination sql2 -SourceSqlCredential $cred -DestinationSqlCredential $cred 
Copy-DbaAgentJob -Source sql1 -SourceSqlCredential $cred -Destination sql2 -DestinationSqlCredential $cred -DisableOnDestination 


#Create new database on target instance, and add a metadatatable to it
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database master -Query "CREATE DATABASE LogShippingMetadata";
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -database LogShippingMetadata -query "CREATE TABLE LogShippingWatermarks (databasename nvarchar(128) CONSTRAINT PK_LogShippingWaterMarks PRIMARY KEY CLUSTERED, LastFull nvarchar(max), LastLSN bigint)"
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -database LogShippingMetadata -query "INSERT LogShippingWatermarks (databasename, LastFull, LastLsn) VALUES('DBA', NULL, 0)"


# Find last full backup. Get-DbaBackupHistory fullname property is a string array. We will be using single backup files, 
#so first item is ours to get 
$backuppath=(Get-DbaDbBackupHistory -SqlInstance sql1 -SqlCredential $cred -Database DBA -LastFull).FullName[0]
Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $backuppath -WithReplace -NoRecovery 

Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -database LogShippingMetadata -query "UPDATE LogShippingWatermarks SET LastFull = @LastFull,lastlsn=0 WHERE databasename = @DBName" -SqlParameters @{ DBName="DBA"; LastFull = $backuppath}

#Now start the log shipping, we have the full backup restored and DB is in norecovery mode
$lastlsn = (Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database LogShippingMetadata -Query "SELECT LastLsn FROM LogShippingWatermarks WHERE databasename=@dbname" -SqlParameters @{dbname = "DBA"}).Item("LastLsn")
$lastlsn
foreach($logbackup in Get-DbaDbBackupHistory -SqlInstance sql1 -SqlCredential $cred -database DBA -Type Log -lastlsn $lastlsn | Sort-Object -Property Start){
    [int64]$lsn=$LogBackup.LastLSN
    $lsn 
    $backuppath = $LogBackup.Path[0] 
    $backuppath 
    Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $backuppath -databasename "DBA" -withreplace -NoRecovery -Continue 
    Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database LogShippingMetadata -Query "UPDATE LogShippingWaterMarks SET LastLsn=@LastLsn WHERE databasename=@dbname" -SqlParameters @{LastLsn=$lsn;DBName="DBA"}
}

Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Database LogShippingMetadata -Query "SELECT * FROM LogShippingWaterMarks"

#Lets run some more transaction log backups
$blobStorageURL="https://tsqlabdbafundamentals.blob.core.windows.net/backups"
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"

#Changing TimestampFormat to allow backups to be created more than once per minute
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"

