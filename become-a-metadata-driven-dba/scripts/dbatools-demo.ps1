Get-DbaService -ComputerName DB1

Get-DbaDatabase -SqlInstance sql1.prod.database.transmokopter.local

Get-DbaDatabase -SqlInstance sql1.prod.database.transmokopter.local | Select-Object -Property Name, Status, RecoveryModel, LogReuseWaitStatus

Get-DbaAgentJob -SqlInstance sql1.prod.database.transmokopter.local -Job 'DatabaseBackup - USER_DATABASES - FULL' 

Get-DbaAgentJob -SqlInstance sql1.prod.database.transmokopter.local -Job 'DatabaseBackup - USER_DATABASES - FULL' | Sort-Object -Property StartDate -Descending -Top 1

Get-DbaAgentJob -SqlInstance sql1.prod.database.transmokopter.local -Job 'DatabaseBackup - USER_DATABASES - FULL'| Start-DbaAgentJob

Get-DbaAgentJobHistory -SqlInstance sql1.prod.database.transmokopter.local -Job 'DatabaseBackup - USER_DATABASES - FULL'

New-DbaDatabase -SqlInstance sql1.prod.database.transmokopter.local

# PowerShell tends to give you rather long lines
# in pwsh, line breaks after pipe works fine

Get-DbaAgentJob -SqlInstance sql1.prod.database.transmokopter.local -Job 'DatabaseBackup - USER_DATABASES - FULL' | 
    Sort-Object -Property StartDate -Descending -Top 1

# But I prefer "splat"

$getDbaAgentJobSplat = @{
    SqlInstance = "sql1.prod.database.transmokopter.local"
    Job = "DatabaseBackup - USER_DATABASES - FULL"
}

$sortObjectSplat = @{
    Property = "StartDate"
    Descending = $true
    Top = 1
}

Get-DbaAgentJob @getDbaAgentJobSplat | Sort-Object @sortObjectSplat

# Very quickly: DbaChecks

# Install-Module dbachecks -Force

# Prerequisite is to have Pester 4.10.0. If you just install the latest, you get 5.6.0 which will not work with current version of dbachecks
# Next version of dbachecks will - I've been told - use Pester 5, and will run even faster
# If you already have 5.6.0 installed, you need to use -SkipPublisherCheck, because there's a change in the certificate between the versions
# of pester, and PowerShell will detect that as 4.10.0 having an untrusted publisher

# Install-Module pester -RequiredVersion 4.10.0 -Force -SkipPublisherCheck

# User requiredversion 4.10.0 before running dbachecks tests
Import-Module pester -RequiredVersion 4.10.0
Invoke-DbcCheck -Check RecoveryModel -SqlInstance sql1.prod.database.transmokopter.local -ExcludeDatabase msdb

