Login-AzAccount
Set-AzContext -Subscription "Microsoft Azure Sponsring"
New-AzResourceGroup -Name TSQLABNet -Location westeurope
$vnetSplat = @{
    ResourceGroupName = "TSQLABNet"
    Location = "westeurope"
    Name = "TSQLABVnet"
    AddressPrefix = "10.1.0.0/16"
}
$virtualNetwork = New-AzVirtualNetwork @vnetSplat

$subnetSplat = @{
    Name = "Frontend"
    AddressPrefix = "10.1.0.0/24"
    VirtualNetwork = $virtualNetwork
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnetSplat

$virtualNetwork | Set-AzVirtualNetwork

$vnet = Get-AzVirtualNetwork -ResourceGroupName TSQLABNet -Name TSQLABVnet 

Add-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.1.255.0/27 -VirtualNetwork $vnet

$vnet | Set-AzVirtualNetwork

$gwpip= New-AzPublicIpAddress -Name TSQLABVnetGWIP -ResourceGroupName TSQLABNet -Location 'westeurope' -AllocationMethod Dynamic

$vnet = Get-AzVirtualNetwork -Name TSQLABVnet -ResourceGroupName TSQLABNet
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name TSQLABVnetGWIP -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id

$vpnSplat = @{
    Name = "TSQLABVnetGW" 
    ResourceGroupName = "TSQLABNet"
    Location = "westeurope"
    IpConfigurations = $gwipconfig
    GateWayType = "Vpn"
    VpnType = "RouteBased"
    GatewaySku = "VpnGw1"
}
New-AzVirtualNetworkGateway @vpnSplat 

Get-AzVirtualNetworkGateway -Name TSQLABVnetGW -ResourceGroup TSQLABNet

$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=P2SRootCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

$P2SRootCertName = "P2SRoot.cer"
$filePathToRootCert = "c:\temp\$P2SRootCertName"


$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathToRootCert)
$CertBase64 = [system.convert]::ToBase64String($cert.RawData)

$Gateway = Get-AzVirtualNetworkGateway -ResourceGroupName TSQLABNet -Name TSQLABVnetGW
$VPNClientAddressPool = "172.16.201.0/24"
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -VpnClientAddressPool $VPNClientAddressPool

Add-AzVpnClientRootCertificate -VpnClientRootCertificateName $P2SRootCertName -VirtualNetworkGatewayname "TSQLABVnetGW" -ResourceGroupName "TSQLABNet" -PublicCertData $CertBase64

$profile=New-AzVpnClientConfiguration -ResourceGroupName TSQLABNet -Name TSQLABVnetGW -AuthenticationMethod "EapTls"

$profile.VPNProfileSASUrl
