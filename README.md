# OpenvSwitch scripts for SDN purposes

These scripts are used to configure a SDN Overlay without breaking connectivity. Therefore, you can run them savely while in a SSH session without worrying about losing connection.

The up.sh script creates an ovs bridge, adds the physical interface into it, configures the IPs and MAC addresses,
subscribes the bridge to a SDN Controller, changes any possible problematic OpenFlow rules if any and updates the routing table.

The down.sh script removes the ovs bridge and resets the configuration.

## Requirements
+ The host runs on Linux.
+ The host is connected to an Ethernet OpenVPN.
+ OpenvSwitch is installed.
+ The host is able to ping the SDN Controller machine.
