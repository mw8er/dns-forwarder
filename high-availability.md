# 2 - High Availability - DNS Forwarder

DNS is an important topic in your setup. This is also true for the dns forwarder. Hence, it is not enough to have only one virtual machine running.

Microsoft Azur provides serveral ways to improve the availability.
1. Single VM (in one availability zone in one region) ... this is the starting point which is already covered with [cloud-init](cloud-init.md)
2. Single datacenter - multiple VMs with
    a. [availability set](availability-set.md)
    b. [virtual machine scale set (VMSS)](vmss.md)
3. Multiple datacenter - [availaibitlity zones wih VMSS](availability-zones.md)
4. [Multiple regions](multiple-regions.md)

For more details check out [Availability options for Azure Virtual Machines](https://docs.microsoft.com/en-us/azure/virtual-machines/availability)