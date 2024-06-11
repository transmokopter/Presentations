. $psscriptroot\Install-TsqlAbSqlInstance.ps1
Function Invoke-TSqlAbTestAndInstallSqlInstance {
    [CmdletBinding()]
    param(
        [string] $ServerName = "",
        [string] $InstanceName = "",
        [string] $SqlVersion = "",
        [string] $Tier = "",
        [string] $ConnectionName = "",
        [switch] $InstallMissing
    )
    $instances = Invoke-RestMethod "http://localhost:8080/GetSqlInstance?ServerName=$ServerName&InstanceName=$InstanceName&SqlVersion=$SqlVersion&Tier=$Tier&ConnectionName=$ConnectionName"
    foreach($instance in $instances){
        if(-not (Get-DbaService -ComputerName $instance.ServerName -InstanceName $instance.InstanceName)){
            Write-Verbose "The following Sql Instance is not installed. $instance"
            
            Write-Verbose "InstallMissing: $InstallMissing"
            if( $InstallMissing ){
                Install-TsqlAbSqlInstance -SqlInstanceInfo $instance -SaCredential (New-Object pscredential("sa",(ConvertTo-SecureString -AsPlainText ([string](New-Guid).Guid) -Force)))
            }
        }
    }
}