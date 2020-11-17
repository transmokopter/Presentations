# To install - use Install-Module
Install-Module dbatools -Repository psgallery -Scope AllUsers -Force; # use -Force to install a new version on top of an existing installation.

# To update, use built in command Update-DbaTools
Update-DbaTools; #Check out -Development switch if you're brave

# First lest's create login credentials

$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# Some commandlets

# Find SQL Server services on a machine
Get-DbaService -Server localhost;

# Filter for Engine servie only
Get-DbaService -Server localhost -Type Engine  
Get-DbaService -Server localhost | Where-Object { $PSItem.ServiceType -eq "Engine" }

# Explore members of the returned object
Get-DbaService -Server localhost -Type Engine | Get-Member;

# Customize result set
Get-DbaService -Server localhost -Type Engine | Select-Object -Property ComputerName, ServiceType, ServiceName, Description, @{ Name = 'ServiceStatus'; Expression = { $_.State } };

# Get output as table 
Get-DbaService -Server localhost -Type Engine | Select-Object -Property ComputerName, ServiceType, ServiceName, Description, @{ Nam e ='ServiceStatus'; Expression = { $_.State } } | Format-Table;

# There are some things I consider standard on a database instance
# I like putting them in their own database instead of master

$dbname = "DBA"
New-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -name $dbname -owner sa

Install-DbaMaintenanceSolution -sqlinstance sql1 -SqlCredential $cred -Database $dbname -ReplaceExisting
Install-DbaFirstResponderKit -SqlInstance sql1 -SqlCredential $cred -Database $dbname 
Install-DbaWhoIsActive -SqlInstance sql1 -SqlCredential $cred -Database $dbname 

$DBALoginpwd = ConvertTo-SecureString -AsPlaintext "Pa55w.rd" -Force
New-DbaLogin -SqlInstance sql1 -SqlCredential $cred -Login DBALogin -Password $DBALoginpwd -PasswordPolicyEnforced:$false

#And with some fancier PS-stuff, a Splat for parameters
$LoginSplat = @{
    SqlInstance             = "sql1"
    SqlCredential           = $cred
    Login                   = "MySecondLogin"
    Password                = $DBALoginpwd
    PasswordPolicyEnforced  = $false 
    EnableException         = $true
}

New-DbaLogin @LoginSplat 
