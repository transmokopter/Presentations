# First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# Replace this with valid path to your container
$blobStorageURL="https://tsqlabdbafundamentals.blob.core.windows.net/backups"

# the secret below won't work, you need to replace with your own
$plaintextSecret="sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2021-11-17T06:00:21Z&st=2020-11-16T22:00:21Z&spr=https&sig=efsyBINzoexDm4V6aya%2BFdrRLsyFUMRXezR50CUUH54%3D"

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

