# High available DNS Forwarder

This repository covers three topics
* Setting up a virtual machine with cloud init
* Setting up a DNS forwarder inspired by [azure-quickstart-templates/demos/dns-forwarder](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/dns-forwarder) ... as mentioned above: with cloud init
* Improving the resiliency of the DNS forwarder, from one virtual machine (VM) to availability set to VM scale set (VMSS) and VMSS with availability zones. (skipping the multi-region scenario)

## Why DNS forwarder?
As illustrated below, a DNS forwarder is useful for doing hostname resolution between virtual networks or from on-premise machines to Azure. See [Name resolution using your own DNS server](https://azure.microsoft.com/documentation/articles/virtual-networks-name-resolution-for-vms-and-role-instances/#name-resolution-using-your-own-dns-server) for more details of how DNS resolution work in Azure.

![Hybrid-scenario DNS](images/hybrid-scenario.png)

# Cloud init
The setup of the DNS forwarder is covered in (cloud-init.yaml).
The first block ensures that the current image is updated and upgraded (including a reboot if required). After that follows the installation of *bind9*. Then we add the example configuration of *bind9* and store it in the file */etc/bind/named.conf.options*. More on that in the following subsection. Finally the cloud init closes with restarting he *bind9* service.

## *bind9* configuration
The acl goodclients contains the IP addresses and names that are allowed to use the DNS forwarder.
*options* contains the configuration of the default target of the DNS forwarder, the *Azure DNS*.
Then follows configuration of the zone *azure.example.com*  which also gets forwarded to the *Azure DNS*. This is necessary since *example.com* in general is forwarded to an *non-Azure DNS*.

# Preparation
After checking out the repository. Upen the file *common.properties* and adjust the value of *sshKeyValues* to match your ssh key.
In addtion, you may want to adjust the value of *location*.

# Setup
The common setup is covered in the script *common.sh*, i.e.
- a resource group
- a virtual network with two subnets, one for Azure Bastion and the other for the actual DNS forwarder.
- an Azure Bastion host (incl. a public ip) to provide to the DNS forwarder without public ip
- an NAT gateway (incl. a public ip) to ensure connecivity form the DNS forwarder to the internet.
- a NSG allowing the port (53) for DNS
- two private DNS zones, each with one entry, to be able to verify the DNS forwarder


# Single VM
To setup a single VM and to verify the cloud-init setup run the shell script *cloud-init-step-1.sh*.

Once the script is finished you can log in to the VM via Azure Bastion.
There you can do the following steps:
- *sudo systemctl status bind9* to verify that the *bind9* service is running
- *cat /etc/bind/named.conf.options* to verify that the configuration of *bind9* is as expected.
- *nslookup succeed.azure.example.com* to verify the connection of the private DNS zone *azure.example.com*. The result should be *192.168.42.42*.
- *nslookup fail.onprem.example.com* to verify the connection of the private DNS zone *onprem.example.com*. The result should be *10.10.42.42*.

After that you're good to run the shell script *cloud-init-step-2.sh*.
This script updates the DNS of your virtual network and restarts the VM. After that you can verify the functionality of your DNS forwarder.

- *sudo systemctl status bind9* to verify that the *bind9* service is running.
- *nslookup succeed.azure.example.com* to verify the connection of the private DNS zone *azure.example.com*. The result should be *192.168.42.42*.
- *nslookup fail.onprem.example.com* to verify the connection of the private DNS zone *onprem.example.com*. The result should be *server can't find fail.onprem.example.com: NXDOMAIN*. Due to the DNS forwarder, the zone *onprem.example.com* is resolved now like the zone *example.com* instead of the Azure DNS.

Since the DNS forwarder, is a critical part of your Azure footprint, you should consider to make it more resilient.

# Availability Set
Using an availability set is the first step towards more resiliency. To setup an availability set (with the verified  cloud-init setup) run the shell script *availability-set-step-1.sh*.

Once the script is finished you can log in to the VMs via Azure Bastion, and verify that everything is working as expected as in the single VM setup.

After that you're good to run the shell script *availability-set-step-2.sh*.
This script updates the DNS of your virtual network and restarts the VMs. After that you can verify the functionality of your DNS forwarder as in the single VM setup.

# Virtual Machine Scale Set
Using an virtual machine scale set (VMSS) is the  step towards more resiliency. To setup a VMSS (with the verified  cloud-init setup) run the shell script *vmss-step-1.sh*.

Once the script is finished you can log in to the VMs via Azure Bastion, and verify that everything is working as expected as in the single VM setup.

After that you're good to run the shell script *vmss-step-2.sh*.
This script updates the DNS of your virtual network and restarts the VMs. After that you can verify the functionality of your DNS forwarder as in the single VM setup.

# Availability Zones
The final step within a single region is the usage of availabilty zones. To setup a VMSS with availability zones (with the verified  cloud-init setup) run the shell script *availability-zones-step-1.sh*.

Once the script is finished you can log in to the VMs via Azure Bastion, and verify that everything is working as expected as in the single VM setup.

After that you're good to run the shell script *availability-zones-step-2.sh*.
This script updates the DNS of your virtual network and restarts the VMs. After that you can verify the functionality of your DNS forwarder as in the single VM setup.

# Multiple Regions
For multiple regions, there are mainly two things to consider:
First, for each region you should decide how to setup that region. Each of the options from above is valid, but regions might have different restrictions, e.g. availability zones not being available.

Second, you should decide about how to connect the two (or more) regions. In case of DNS forwarder, we simply list the additional IP addresses in the virtual networks or the firewall proxy.

# Enterprise Scenario
In an enterprise scenario, the VNet of the DNS forwarder might a spoke in an hub-and-spoke (traditional or virtual WAN) setup. In that case, you could replace the NAT gateway with the (Azure) firewall in the hub.