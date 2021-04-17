# To install - use Install-Module
# use -Force to install a new version on top of an existing installation.
Install-Module dbatools -Repository psgallery -Scope AllUsers -Force; 

# To update, use built in command Update-DbaTools
#Check out -Development switch if you're brave
Update-DbaTools -Development; 

# First lest's create a powershell object with login credentials
$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

# There are some things I consider standard on a database instance
# I like putting them in their own database instead of master
$dbName = "DBA"
New-DbaDatabase -SqlInstance "localhost,1401" -SqlCredential $cred -name $dbname -owner sa

$installSplat = @{
    SqlInstance         = "localhost,1401"
    SqlCredential       = $cred 
    Database            = $dbName
}
Install-DbaMaintenanceSolution @installSplat -ReplaceExisting
Install-DbaFirstResponderKit @installSplat 
Install-DbaWhoIsActive @installSplat

$DBALoginpwd = ConvertTo-SecureString -AsPlaintext "Pa55w.rd" -Force
$loginSplat = @{
    SqlInstance             = "localhost,1401"
    SqlCredential           = $cred
    Password                = $DBALoginpwd
    PasswordPolicyEnforced  = $false 
}

New-DbaLogin @loginSplat -Login DBALogin
New-DbaLogin @LoginSplat -Login SecondLogin 

# Restore AdventureWorks to the sql1 container
$restoreSplat = @{
    SqlInstance            = "localhost,1401"
    SqlCredential          = $cred
    Path                   = "/var/opt/mssql/data/AdventureWorks2014.bak"
}
Restore-DbaDatabase @restoreSplat 

