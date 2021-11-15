#!/bin/sh

prefix=$1
location=$2

. common.properties

# # login and switch to desired subscription
# az login
# az account set --subscription "..."

az group create --name $resourceGroup --location $location

az network vnet create \
    --resource-group $resourceGroup \
    --location $location \
    --name $vnetName \
    --address-prefixes $vnetAddressPrefix \
    --subnet-name $subnetName \
    --subnet-prefixes $subnetAddressPrefix

az network vnet subnet create \
    --resource-group $resourceGroup \
    --name AzureBastionSubnet \
    --vnet-name $vnetName \
    --address-prefixes $bastionSubnetAddressPrefix

az network public-ip create \
    --resource-group $resourceGroup \
    --name $bastionPipName \
    --sku Standard

az network bastion create \
    --resource-group $resourceGroup \
    --name $bastionName \
    --public-ip-address $bastionPipName \
    --vnet-name $vnetName \
    --location $location

az network public-ip create \
    --resource-group $resourceGroup \
    --name $natPipName \
    --sku Standard \
    --allocation static

az network nat gateway create \
    --resource-group $resourceGroup \
    --name $natName \
    --public-ip-addresses $natPipName \
    --idle-timeout 10

az network vnet subnet update \
    --resource-group $resourceGroup \
    --vnet-name $vnetName \
    --name $subnetName \
    --nat-gateway $natName

az network nsg create \
    --resource-group $resourceGroup \
    --name $nsgName

az network nsg rule create \
    --resource-group $resourceGroup \
    --nsg-name $nsgName \
    --name dns \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 53 \
    --access allow \
    --priority 200

az network private-dns zone create \
  --name $azureZone \
  --resource-group $resourceGroup

az network private-dns zone create \
  --name $onpremZone \
  --resource-group $resourceGroup

az network private-dns link vnet create \
  --name $azureZone \
  --registration-enabled false \
  --resource-group $resourceGroup \
  --virtual-network $vnetName \
  --zone-name $azureZone

az network private-dns link vnet create \
  --name $onpremZone \
  --registration-enabled false \
  --resource-group $resourceGroup \
  --virtual-network $vnetName \
  --zone-name $onpremZone

az network private-dns record-set a add-record \
  --ipv4-address 192.168.42.42 \
  --record-set-name succeed \
  --resource-group $resourceGroup \
  --zone-name $azureZone

az network private-dns record-set a add-record \
  --ipv4-address 10.10.42.42 \
  --record-set-name fail \
  --resource-group $resourceGroup \
  --zone-name $onpremZone
