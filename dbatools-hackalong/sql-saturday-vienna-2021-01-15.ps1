# Explore databases
Get-DbaDatabase -SqlInstance sql1 -SqlCredential $cred
Get-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -UserDbOnly

# Create new database
New-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -Database dba 

Start-DbaAgentJob -SqlInstance sql1 -SqlCredential $cred -Job "FULL BACKUP"

# Download First Responder Kit, spWhoIsActive etc
Install-DbaFirstResponderKit -SqlInstance sql1 -SqlCredential $cred -Database dba 
Install-DbaMaintenanceSolution -SqlInstance sql1 -SqlCredential $cred -Database dba 
Install-DbaWhoIsActive -SqlInstance sql1 -SqlCredential $cred -Database dba 


# Explore the backups for a database
$lastFull = Get-DbaDbBackupHistory -SqlInstance sql1 -Database AdventureWorks2014 -LastFull -SqlCredential $cred 
$lastFull
$lastLsn = $LastFull.LastLsn 
[string]$lastFullPath = $LastFull.FullName


# This loop will do a full restore test, using the last full backup and all the following transaction log backups from instance sql1 and restore to instance sql2.
Get-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -UserDbOnly | ForEach-Object {
    $dbname = $PSItem.Name
    $lastFull = Get-DbaDbBackupHistory -SqlInstance sql1 -Database $dbname -LastFull -SqlCredential $cred 
    $lastFull
    $lastLsn = $LastFull.LastLsn 
    [string]$lastFullPath = $LastFull.FullName
    Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $lastFullPath -WithReplace -NoRecovery
    Get-DbaDbBackupHistory -Type Log -LastLsn $lastLsn -SqlInstance sql1 -SqlCredential $cred -Database $dbname | Sort-Object -property start | ForEach-Object {
        $logBackupPath = $PSItem.FullName 
        Restore-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -Path $logBackupPath -WithReplace -NoRecovery -Continue
    }
}

# Look at the result
Get-DbaDatabase -SqlInstance sql2 -SqlCredential $cred -UserDbOnly


# I start this one in another window, so I get a countdown-timer for my session
Function Start-TransmokopterTimer{
    param(
         $minutes 

    )
$end = (get-date).AddMinutes($minutes)
while($now -lt $end){
    Clear-Host
    $now = get-date
    $minute = ($end-$now).Minutes
    $second = ($end-$now).Seconds
    Write-Host "$minute´:$second" -ForegroundColor cyan 
    start-sleep -seconds 5
}
Clear-Host 
Write-Host -ForegroundColor Red "Time is up"
}
