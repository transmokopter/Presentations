# First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# Replace this with valid path to your container
$blobStorageURL="https://transmokopterpsdemo.blob.core.windows.net/backups"

# the secret below won't work, you need to replace with your own
$plaintextSecret="sp=racwdl&st=2021-04-17T13:19:24Z&se=2021-12-31T22:19:24Z&spr=https&sv=2020-02-10&sr=c&sig=0EZzE6taGUcgZK0%2BmVXCYFAJckU9xzGL6rBKfGqfGNg%3D"

# We also need secure string for credential password for blob storage
$blobstoragepassword = ConvertTo-SecureString -AsPlainText $plaintextSecret -Force


New-DbaCredential -SqlInstance "localhost,1401" -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force
New-DbaCredential -SqlInstance "localhost,1402" -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


# two instances at once
New-DbaCredential -SqlInstance "localhost,1401", "localhost,1402" -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


# and fancy schmancy way to do it
$NewCredentialSplat=@{
    SqlInstance                 = "localhost,1401", "localhost,1402"
    SqlCredential               = $cred 
    Name                        = $blobStorageURL
    Identity                    = "shared access signature"
    SecurePassword              = $blobstoragepassword
}
New-DbaCredential @NewCredentialSplat -Force

$dbname = "DBA"
Backup-DbaDatabase -SqlInstance "localhost,1401" -SqlCredential $cred -Database $dbname -AzureBaseUrl $blobStorageURL -Type Full
# Look at container

#Add some cool folder structure
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"
Backup-DbaDatabase -SqlInstance "localhost,1401" -SqlCredential $cred -Database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.bak -CompressBackup -ReplaceInName -Type Full 
#-TimeStampFormat "yyyyMMddhhmmss"
#Ok, I like that structure. Let's backup transaction log too
Backup-DbaDatabase -SqlInstance "localhost,1401" -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"

#Restore AdventureWorks2014 from Storage-container
$restoreDbaDatabaseSplat = @{
    SqlInstance = "localhost,1401"
    SqlCredential = $cred 
    Path = "https://transmokopterpsdemo.blob.core.windows.net/backups/AdventureWorks2014.bak"
    WithReplace = $true

}
Restore-DbaDatabase @restoreDbaDatabaseSplat
Set-DbaDbRecoveryModel -SqlInstance "localhost,1401" -SqlCredential $cred -Database AdventureWorks2014 -RecoveryModel Full -Confirm:$false

#Create backup jobs
New-DbaAgentJob -SqlInstance "localhost,1401" -SqlCredential $cred -Job "FULL_BACKUP" 
New-DbaAgentJob -SqlInstance "localhost,1401" -SqlCredential $cred -Job "LOG_BACKUP" 

$fullBackupCommand = "EXEC dba.dbo.DatabaseBackup @Databases = N'USER_DATABASES',              -- nvarchar(max)
@URL = N'https://transmokopterpsdemo.blob.core.windows.net/backups',
@BackupType = N'FULL'"
$logBackupCommand = "EXEC dba.dbo.DatabaseBackup @Databases = N'USER_DATABASES',              -- nvarchar(max)
@URL = N'https://transmokopterpsdemo.blob.core.windows.net/backups',
@BackupType = N'LOG'"
$agentJobStepBaseSplat = @{
    SqlInstance = "localhost,1401"
    SqlCredential = $cred
    Database = "DBA"
    SubSystem = "TransactSql"
}
New-DbaAgentJobStep @agentJobStepBaseSplat -StepName "Run backups" -Command $fullBackupCommand -Job "FULL_BACKUP"
New-DbaAgentJobStep @agentJobStepBaseSplat -StepName "Run log backups" -Command $logBackupCommand -Job "LOG_BACKUP"

$agentJobScheduleBaseSplat = @{
    SqlInstance = "localhost,1401"
    SqlCredential = $cred 
    FrequencyType = "Daily"
    FrequencyInterval = 1
    FrequencySubdayInterval = 1
}
New-DbaAgentSchedule @agentJobScheduleBaseSplat -Schedule "BACKUP_EVERY_MINUTE" -Job "LOG_BACKUP" -FrequencySubdayType Minutes -Force
New-DbaAgentSchedule @agentJobScheduleBaseSplat -Schedule "BACKUP_EVERY_HOUR" -Job "FULL_BACKUP" -FrequencySubdayType Hours -Force

Start-DbaAgentJob -SqlInstance "localhost,1401" -SqlCredential $cred -Job "FULL_BACKUP"

