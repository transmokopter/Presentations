# To install - use Install-Module
Install-Module dbatools -Repository psgallery -Scope AllUsers -Force; # use -Force to install a new version on top of an existing installation.

# To update, use built in command Update-DbaTools
Update-DbaTools; #Check out -Development switch if you're brave

# First lest's create a powershell with login credentials

$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

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
