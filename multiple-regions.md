# Multiple Regions

There are mainly two things to consider:
First, for each region you should decide how to setup that region. Each of the single region options is valid, but regions might have different restrictions, e.g. availability zones not being available.

Second, you should decide about how to connect the two (or more) regions. In case of dns forwarder, we simply list the additional IP addresses in the virtual networks.
