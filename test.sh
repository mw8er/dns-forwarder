#!/bin/sh

export prefix="mwa-dnsforwarder"
export sshKeyValues="@/Users/mw8er/.ssh/id_rsa.pub"
export location="westeurope"

export resourceGroup="${prefix}-rg"
export dnsPrefix="${prefix}-dns"
export testPrefix="${prefix}-test"
export dnsVmName="${dnsPrefix}-vm"
export testVmName="${testPrefix}-vm"
export dnsPipName="${dnsPrefix}-public-ip"
export testPipName="${testPrefix}-public-ip"
export dnsOsDiskName="${dnsPrefix}-os-disk"
export testOsDiskName="${testPrefix}-os-disk"
export dnsNsgName="${dnsPrefix}-nsg"
export testNsgName="${testPrefix}-nsg"
export dnsVnetName="${dnsPrefix}-vnet"
export testVnetName="${testPrefix}-vnet"
export dnsZone="azure.example.com"

export image="Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest"
export dnsVnetAddressPrefix="192.168.86.0/28"
export dnsSubnetName="dns-subnet"
export dnsSubnetAddressPrefix="192.168.86.0/28"
export dnsIPv4="192.168.86.4"
export testVnetAddressPrefix="192.168.86.16/28"
export testSubnetName="test-subnet"
export testSubnetAddressPrefix="192.168.86.16/28"
export testIPv4="192.168.86.20"

# # login and switch to desired subscription
# az login --use-device-code
# az account set --subscription "iptch Sandbox"

az group create --name $resourceGroup --location $location

az vm create \
  --resource-group $resourceGroup \
  --name $dnsVmName \
  --computer-name dns \
  --os-disk-name $dnsOsDiskName \
  --image $image \
  --admin-username azureuser \
  --public-ip-address $dnsPipName \
  --nsg $dnsNsgName \
  --vnet-name $dnsVnetName \
  --vnet-address-prefix $dnsVnetAddressPrefix \
  --subnet $dnsSubnetName \
  --subnet-address-prefix $dnsSubnetAddressPrefix \
  --public-ip-sku Basic \
  --custom-data cloud-init.yaml \
  --ssh-key-values ${sshKeyValues}
  
az vm open-port --port 53 --resource-group $resourceGroup --name $dnsVmName --priority 1100

az vm create \
  --resource-group $resourceGroup \
  --name $testVmName \
  --computer-name test \
  --os-disk-name $testOsDiskName \
  --image $image \
  --admin-username azureuser \
  --public-ip-address $testPipName \
  --nsg $testNsgName \
  --vnet-name $testVnetName \
  --vnet-address-prefix $testVnetAddressPrefix \
  --subnet $testSubnetName \
  --subnet-address-prefix $testSubnetAddressPrefix \
  --public-ip-sku Basic \
  --ssh-key-values ${sshKeyValues}


az network private-dns zone create \
  --name $dnsZone \
  --resource-group $resourceGroup

az network private-dns link vnet create \
  --name $dnsZone \
  --registration-enabled false \
  --resource-group $resourceGroup \
  --virtual-network $dnsVnetName \
  --zone-name $dnsZone

az network private-dns record-set a add-record \
  --ipv4-address $dnsIPv4 \
  --record-set-name dns \
  --resource-group $resourceGroup \
  --zone-name $dnsZone

az network private-dns record-set a add-record \
  --ipv4-address $testIPv4 \
  --record-set-name test \
  --resource-group $resourceGroup \
  --zone-name $dnsZone

az network vnet peering create \
  --name dns \
  --remote-vnet $dnsVnetName \
  --resource-group $resourceGroup \
  --vnet-name $testVnetName \
  --allow-vnet-access

az network vnet peering create \
  --name dns \
  --remote-vnet $testVnetName \
  --resource-group $resourceGroup \
  --vnet-name $dnsVnetName \
  --allow-vnet-access

az network vnet update \
  --name $dnsVnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

az network vnet update \
  --name $testVnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

az vm restart \
  --name $dnsVmName \
  --resource-group $resourceGroup

az vm restart \
  --name $testVmName \
  --resource-group $resourceGroup
