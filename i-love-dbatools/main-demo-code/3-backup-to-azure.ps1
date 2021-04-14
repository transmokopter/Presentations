# First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# Replace this with valid path to your container
$blobStorageURL="https://transmokopterpsdemo.blob.core.windows.net/backups"

# the secret below won't work, you need to replace with your own
$plaintextSecret="sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2021-01-30T16:45:51Z&st=2021-01-29T08:45:51Z&spr=https&sig=UJVKiQRrS8HeqCf%2FCqPOw0CiOQ9a4Ll%2FZ8Nw%2FktcYBk%3D"

# We also need secure string for credential password for blob storage
$blobstoragepassword = ConvertTo-SecureString -AsPlainText $plaintextSecret -Force


New-DbaCredential -SqlInstance sql1 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force
New-DbaCredential -SqlInstance sql2 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


# two instances at once
New-DbaCredential -SqlInstance sql1, sql2 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


# and fancy schmancy way to do it
$NewCredentialSplat=@{
    SqlInstance                 = "sql1", "sql2"
    SqlCredential               = $cred 
    Name                        = $blobStorageURL
    Identity                    = "shared access signature"
    SecurePassword              = $blobstoragepassword
}
New-DbaCredential @NewCredentialSplat -Force

$dbname = "DBA"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $blobStorageURL -Type Full
# Look at container

#Add some cool folder structure
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.bak -CompressBackup -ReplaceInName -Type Full 
#-TimeStampFormat "yyyyMMddhhmmss"
#Ok, I like that structure. Let's backup transaction log too
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"

#Restore AdventureWorks2014 from Storage-container
$restoreDbaDatabaseSplat = @{
    SqlInstance = "sql1"
    SqlCredential = $cred 
    Path = "https://transmokopterpsdemo.blob.core.windows.net/backups/AdventureWorks2014.bak"
    WithReplace = $true

}
Restore-DbaDatabase @restoreDbaDatabaseSplat
Set-DbaDbRecoveryModel -SqlInstance sql1 -SqlCredential $cred -Database AdventureWorks2014 -RecoveryModel Full -Confirm:$false

#Create backup jobs
New-DbaAgentJob -SqlInstance sql1 -SqlCredential $cred -Job "FULL_BACKUP" 
New-DbaAgentJob -SqlInstance sql1 -SqlCredential $cred -Job "LOG_BACKUP" 

$fullBackupCommand = "EXEC dba.dbo.DatabaseBackup @Databases = N'USER_DATABASES',              -- nvarchar(max)
@URL = N'https://transmokopterpsdemo.blob.core.windows.net/backups',
@BackupType = N'FULL'"
$logBackupCommand = "EXEC dba.dbo.DatabaseBackup @Databases = N'USER_DATABASES',              -- nvarchar(max)
@URL = N'https://transmokopterpsdemo.blob.core.windows.net/backups',
@BackupType = N'LOG'"
$agentJobStepBaseSplat = @{
    SqlInstance = "sql1"
    SqlCredential = $cred
    Database = "DBA"
    SubSystem = "TransactSql"
}
New-DbaAgentJobStep @agentJobStepBaseSplat -StepName "Run backups" -Command $fullBackupCommand -Job "FULL_BACKUP"
New-DbaAgentJobStep @agentJobStepBaseSplat -StepName "Run log backups" -Command $logBackupCommand -Job "LOG_BACKUP"

$agentJobScheduleBaseSplat = @{
    SqlInstance = "sql1"
    SqlCredential = $cred 
    FrequencyType = "Daily"
    FrequencyInterval = 1
    FrequencySubdayInterval = 1
}
New-DbaAgentSchedule @agentJobScheduleBaseSplat -Schedule "BACKUP_EVERY_MINUTE" -Job "LOG_BACKUP" -FrequencySubdayType Minutes -Force
New-DbaAgentSchedule @agentJobScheduleBaseSplat -Schedule "BACKUP_EVERY_HOUR" -Job "FULL_BACKUP" -FrequencySubdayType Hours -Force

Start-DbaAgentJob -SqlInstance sql1 -SqlCredential $cred -Job "FULL_BACKUP"

