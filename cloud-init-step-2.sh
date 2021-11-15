#!/bin/sh

prefix="dns-fwd-cloud-init"
location="westeurope"

. common.properties

vmName="${prefix}-vm"
dnsIPv4="192.168.86.4"

az network vnet update \
  --name $vnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

az vm restart \
  --name $vmName \
  --resource-group $resourceGroup
