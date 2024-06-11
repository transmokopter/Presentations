Function Install-TsqlAbSqlInstance {
    [CmdletBinding()]
    param(
        [pscustomobject]
        $SqlInstanceInfo,
        [pscredential]
        $SaCredential
    )

    $userDomain = $env:USERDOMAIN
    $username = $env:USERNAME
    $fullUsername = "$userdomain\$username"
    $sqlInstance = "$($SqlInstanceInfo.ServerName)\$($SqlInstanceInfo.InstanceName)"
    $sqlVersion = $sqlInstance.SqlVersion


    $InstallSplat = @{
        Version = $SqlInstanceInfo.SqlVersion 
        SqlInstance = $sqlInstance
        Port = 1433
        SaCredential = $SaCredential
        Feature = "Engine"
        AuthenticationMode = "Windows"
        InstancePath = $SqlInstanceInfo.InstanceRoot
        DataPath = $SqlInstanceInfo.DataDir
        LogPath = $SqlInstanceInfo.LogDir
        TempPath = $SqlInstanceInfo.TempDbDir
        BackupPath = $SqlInstanceInfo.BackupPath
        Path = $SqlInstanceInfo.InstallationMediaPath
        AdminAccount = $fullUsername
        Restart = $true 
    }

    Install-DbaInstance @InstallSplat

    Set-DbaTcpPort -SqlInstance $SqlInstance -Port 1433 -IpAddress ($SqlInstanceInfo.IP)

    Restart-DbaService -SqlInstance $SqlInstance -Type Engine -Force 

}