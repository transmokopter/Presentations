# cleanup from old demo runs
docker stop oslo1
docker rm oslo1
docker volume rm oslovolume1

Set-DbatoolsConfig -FullName "sql.connection.trustcert" -Value $true 

# Let's first create a database environment. We'll use docker.
docker run --name oslo1 --hostname oslo1 -p 1600:1433 -v oslovolume1:/var/opt/mssql -d -e "ACCEPT_EULA=YES" -e "SA_PASSWORD=Pa55w.rd" mcr.microsoft.com/mssql/server:latest

# Let's explore some useful dbatools-commands

# Connect to an instance which doesn't have a proper server cert => SQL Server presents a self-signed one
$credentials = Get-Credential
$c = Connect-DbaInstance -SqlInstance "localhost,1600" -TrustServerCertificate -SqlCredential $credentials

$c 
$c | Select-Object -Property *
# short-name for sql-people :)
$c | SELECT *

# Create a new database. Splat makes the code more readbale
$newDbaDatabaseSplat = @{
    SqlInstance = $c
    Database = "dbatoolsdemo"
}
New-DbaDatabase @newDbaDatabaseSplat

# Let's examine this new database.
# Get-DbaDatabase-parameter-wise we need the same that we used to create the DB, so we reuse the splat

Get-DbaDatabase @newDbaDatabaseSplat

# Examine the last full backup for all databases on this system
Get-DbaDbBackupHistory -SqlInstance $c -LastFull

#oooooooops. Not good. We need backups, right?

Backup-DbaDatabase -SqlInstance $c -Type Full

# So.. Here's a dbatools / SMO thing that's interesting...
# I have a connection. It was made before I ran Backups. The connection has cached some database 
# information for me. One of the cached things is Last Full Backup. So If I don't reconnect, 
# for the rest of the demo, my functions will think I don't have a last full backup
$c = Connect-DbaInstance -SqlInstance "localhost,1600" -TrustServerCertificate -SqlCredential $credentials

# Rerun Get-DbaDbBackupHistory
Get-DbaDbBackupHistory -SqlInstance $c -LastFull

# Ok, I want to see which backup-files we have
Get-DbaDbBackupHistory -SqlInstance $c -LastFull | Select-Object -Property Database, Fullname, Start 

# Notice how the Full-name is a collection? Backups can be more than one file. But these aren't
Get-DbaDbBackupHistory -SqlInstance $c -LastFull | 
    Select-Object -Property Database, @{Name = "Fullname"; Expression={$PSItem.Fullname}}, Start 
# Yeah, that's a little odd. PowerShell works in mysterious ways sometimes :)

# Cool, now let's TEST the backups. 
# We should really test against another instance, but this is for demos so...
# If you specify another destination, backups need to either be in a location where destination
# can reach them. Or you have to use CopyFile. etc etc etc
# Check this out for a lot of examples: https://www.sqlshack.com/validate-backups-with-sql-restore-database-operations-using-dbatools/
Test-DbaLastBackup -SqlInstance $c -Database dbatoolsdemo -SqlCredential $credentials

# Let's try it for all databases

Test-DbaLastBackup -SqlInstance $c -SqlCredential $credentials



