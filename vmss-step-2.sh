#!/bin/sh

prefix="dns-fwd-vmss"
location="westeurope"

. common.properties

vmssName="$prefix"
dnsIPv4="192.168.86.4 192.168.86.5"

az network vnet update \
  --name $vnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

az vmss restart \
  --name $vmssName \
  --resource-group $resourceGroup
