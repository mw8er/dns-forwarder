#!/bin/sh

prefix="dns-fwd-az"
sshKeyValues="@/Users/mw8er/.ssh/id_rsa.pub"
location="westeurope"

. common.properties

./common.sh $prefix $location

export vmssName="$prefix-vmss"

az vmss create \
  --resource-group $resourceGroup \
  --name $vmssName \
  --image $image \
  --upgrade-policy-mode automatic \
  --custom-data cloud-init.yaml \
  --admin-username azureuser \
  --vnet-name $vnetName \
  --subnet $subnetName \
  --load-balancer "" \
  --zones 1 2 3 \
  --ssh-key-values ${sshKeyValues} 

