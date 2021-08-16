# First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# Replace this with valid path to your container
$blobStorageURL="https://transmokopterpsdemo.blob.core.windows.net/backups"

# the secret below won't work, you need to replace with your own
$plaintextSecret="sp=racwdl&st=2021-06-12T17:56:01Z&se=2021-06-20T01:56:01Z&spr=https&sv=2020-02-10&sr=c&sig=M2rM%2B6OoJCGxbBgRoRqr%2BCEAXn7VTeEWkW0gzWQ%2BzG0%3D"

# We also need secure string for credential password for blob storage
$blobstoragepassword = ConvertTo-SecureString -AsPlainText $plaintextSecret -Force

$credentialSplat = @{
    SqlCredential           = $cred 
    Name                    = $blobStorageURL
    Identity                = "shared access signature"
    SecurePassword          = $blobStoragePassword 
    Force                   = $true 
}
New-DbaCredential @credentialSplat -SqlInstance "localhost,1401"
New-DbaCredential @credentialSplat -SqlInstance "localhost,1402" 


# two instances at once
"localhost,1401","localhost,1402" | ForEach-Object {
    New-DbaCredential @credentialSplat -SqlInstance $PSItem 
}



$dbname = "DBA"
$backupSplat = @{
    SqlInstance         = "localhost,1401"
    SqlCredential       = $cred 
    Database            = $dbName 
    Type                = "FULL"
    CompressBackup      = $true 
}
Backup-DbaDatabase @backupSplat -AzureBaseUrl $blobStorageURL
# Look at container in browser

#Add some cool folder structure

$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"
Backup-DbaDatabase @backupSplat -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.bak -ReplaceInName
#-TimeStampFormat "yyyyMMddhhmmss"
#Ok, I like that structure. Let's backup transaction log too
$logBackupSplat = @{
    SqlInstance         = "localhost,1401"
    SqlCredential       = $cred 
    Database            = $dbName 
    Type                = "LOG"
    CompressBackup      = $true 
    AzureBaseUrl        = $backupPathPattern
    FilePath            = "dbname_timestamp_backuptype.trn"
    ReplaceInName       = $true 
    TimeStampFormat     = "yyyyMMddhhmmss"
}

Backup-DbaDatabase @logBackupSplat 


$setRecoveryModelSplat = @{
    SqlInstance         = "localhost,1401"
    SqlCredential       = $cred 
    Database            = "AdventureWorks2014"
    RecoveryModel       = "Full"
    Confirm             = $false  
}
Set-DbaDbRecoveryModel @setRecoveryModelSplat 

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

