#!/bin/sh

prefix="dns-fwd-az"

. common.properties

vmssName="$prefix-vmss"
dnsIPv4="192.168.86.5 192.168.86.7"

az network vnet update \
  --name $vnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

az vmss restart \
  --name $vmssName \
  --resource-group $resourceGroup
