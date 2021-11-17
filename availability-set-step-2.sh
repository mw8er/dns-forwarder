#!/bin/sh

prefix="dns-fwd-avail-set"

. common.properties

dnsIPv4="192.168.86.4 192.168.86.5"

az network vnet update \
  --name $vnetName \
  --resource-group $resourceGroup \
  --dns-servers $dnsIPv4

for i in `seq 1 2`; do
    az vm restart \
    --name ${prefix}-${i}-vm \
    --resource-group $resourceGroup
done