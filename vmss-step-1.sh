#!/bin/sh

export prefix="dns-fwd-vmss"
sshKeyValues="@/Users/mw8er/.ssh/id_rsa.pub"
location="westeurope"

. common.properties

./common.sh $prefix $location

export vmssName="$prefix"

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
  --ssh-key-values ${sshKeyValues}

