#!/bin/sh

prefix="dns-fwd-avail-set"
sshKeyValues="@/Users/mw8er/.ssh/id_rsa.pub"
location="westeurope"

. common.properties

./common.sh $prefix $location

export availabilitySetName="${prefix}-avail"

az vm availability-set create \
    --resource-group $resourceGroup \
    --name $availabilitySetName \
    --platform-fault-domain-count 2 \
    --platform-update-domain-count 2

for i in `seq 1 2`; do
    az vm create \
        --resource-group $resourceGroup \
        --name ${prefix}-${i}-vm \
        --computer-name dns${i} \
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
        --name ${prefix}-${i}-vm  \
        --priority 1100

done

