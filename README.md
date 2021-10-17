# DNS Forwarder VM

[![Deploy To Azure](https://raw.githubusercontent.com/mw8er/dns-forwarder/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmw8er%2Fdns-forwarder%2Fazuredeploy.json) 

Inspired by [azure-quickstart-templates/demos/dns-forwarder](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/dns-forwarder)

This template shows how to create a DNS server that forwards queries to Azure's internal DNS servers so that hostnames for VMs in the virtual network can be resolved from outside the network.

In contrast to [azure-quickstart-templates/demos/dns-forwarder](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/dns-forwarder) this template employs a cloud-init file instead of a shell script to setup the DNS service.

Nearly all queries are forwarded to Azure's internal DNS servers so that hostnames for VMs in the virtual network can be resolved from outside the network.
```
options {
    directory "/var/cache/bind";
    allow-query { goodclients; };
    forwarders {
        168.63.129.16;
    };
    forward only;
    dnssec-enable yes;
    dnssec-validation yes;
    auth-nxdomain no;    # conform to RFC1035
    listen-on { any; };
};
```

However, queries about the zone example.com are forwarded to Cloudflare's DNS 1.1.1.1. This way your on-premises names are resolved.
```
zone "example.com" {
    type forward;
    forward only;
    forwarders {
        1.1.1.1;
        1.0.0.1;
        2606:4700:4700::1111;
        2606:4700:4700::1001;
    };
};
```

The exception are quries about the zone azure.example.com which again are  forwarded to Azure's internal DNS servers.
```
zone "azure.example.com" {
    type forward;
    forward only;
    forwarders {
        168.63.129.16;
    };
};
```

How to use this cloud-init template?
Adjust the file *cloud-init.yaml*
1. Adjust the name on-premisses zone, here: *example.com*.
2. Adjust the ip addresses of your on-premisses DNS servers, here: *1.1.1.1*, *1.0.0.1*, *2606:4700:4700::1111* and *2606:4700:4700::1001*.
3. Repeat steps 1. and 2. for further on-premisses zones
4. Adjust the name of azure sub-zones of your on-premisses zones, here: *azure.example.com* or remove that block.
5. Repeat steps 4. for azure sub-zones of your on-premisses zones
6. Adjust yout good clients list according to your needs, here: *10.0.0.0/8*, *172.16.0.0/12*, *192.168.0.0/16*, *localhost* and *localnets*.

In case you would like to verify it in your subscription, please update the script test.sh to match your situation, i.e. the prefix and the location of your public ssh-key.

Including cloud-init in the arm template as mentioned on [ARM Templates and Cloud Init by Ken Muse](https://www.wintellect.com/arm-templates-and-cloud-init/).