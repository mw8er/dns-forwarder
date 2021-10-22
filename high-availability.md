# 2 - High Availability - DNS Forwarder

DNS is an important topic in your setup. This is also true for the dns forwarder. Hence, it is not enough to have only one virtual machine running.

Microsoft Azur provides serveral ways to improve the availability.
1. Single VM (in one availability zone in one region)
2. Single Datacenter - multiple VMs
3. Multiple Datacenter - multiple VMS
4. Multiple Regions - with either 1,2, or 3