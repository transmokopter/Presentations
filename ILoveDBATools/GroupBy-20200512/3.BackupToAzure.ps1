#First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

#Replace this with valid path to your container
$blobStorageURL="https://transmokoptergroupbydemo.blob.core.windows.net/backups"
#the secret below won't work, you need to replace with your own
$plaintextSecret="sv=2019-10-10&ss=bfqt&srt=sco&sp=rwdlacupx&se=2099-05-12T04:42:35Z&st=2020-05-11T20:42:35Z&spr=https&sig=l1asCUA1HXvnUh8Rk%2BoMmKB3pGH1YeGmsyZZmjkY2H8%3D"
#We also need secure string for credential password for blob storage
$blobstoragepassword = ConvertTo-SecureString -AsPlainText $plaintextSecret -Force


New-DbaCredential -SqlInstance sql1 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force
New-DbaCredential -SqlInstance sql2 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


#two instances at once
New-DbaCredential -SqlInstance sql1, sql2 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


#and fancy schmancy way to do it
$NewCredentialSplat=@{
    SqlInstance                 = "sql1", "sql2"
    SqlCredential               = $cred 
    Name                        = $blobStorageURL
    Identity                    = "shared access signature"
    SecurePassword              = $blobstoragepassword
}
New-DbaCredential @NewCredentialSplat

$dbname = "DBA"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $blobStorageURL -Type Full
# Look at container

#Add some cool folder structure
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.bak -CompressBackup -ReplaceInName -Type Full 
#-TimeStampFormat "yyyyMMddhhmmss"
#Ok, I like that structure. Let's backup transaction log too
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log -TimeStampFormat "yyyyMMddhhmmss"

