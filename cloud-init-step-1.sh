#!/bin/sh

prefix="dns-fwd-cloud-init"

. common.properties

./common.sh $prefix $location

vmName="${prefix}-vm"
dnsIPv4="192.168.86.4"

az vm create \
  --resource-group $resourceGroup \
  --name $vmName \
  --computer-name dns \
  --image $image \
  --admin-username azureuser \
  --nsg $nsgName \
  --vnet-name $vnetName \
  --subnet $subnetName \
  --public-ip-address "" \
  --custom-data cloud-init.yaml \
  --ssh-key-values ${sshKeyValues}

az vm open-port \
    --port 53 \
    --resource-group $resourceGroup \
    --name $vmName  \
    --priority 1100
