#First lest's create login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

#Replace this with valid path to your container
$blobStorageURL="https://transmokopterdemo.blob.core.windows.net/backups"
#the secret below won't work, you need to replace with your own
$plaintextSecret="sv=2019-02-02&ss=bfqt&srt=sco&sp=rwdlacup&se=2099-04-16T08:01:49Z&st=2020-04-16T00:01:49Z&spr=https&sig=R5z5HsK7lriLP%2BDPpJcsGjq%2BX121cEovqjFNUA9N3bA%3D"
#We also need secure string for credential password for blob storage
$blobstoragepassword = ConvertTo-SecureString -AsPlainText $plaintextSecret -Force


New-DbaCredential -SqlInstance sql1 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force
New-DbaCredential -SqlInstance sql2 -SqlCredential $cred -Name $blobStorageURL -Identity "shared access signature" -SecurePassword $blobstoragepassword -Force


$dbname = "DBA"


Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $blobStorageURL -Type Full


#Add some cool folder structure
$backupPathPattern="$blobStorageURL/servername/instancename/backuptype/dbname/"
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.bak  -CompressBackup -ReplaceInName -Type Full

#Ok, I like that structure. Let's backup transaction log too
Backup-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -database $dbname -AzureBaseUrl $backupPathPattern -filepath dbname_timestamp_backuptype.trn  -CompressBackup -ReplaceInName -type Log 

