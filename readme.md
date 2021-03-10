netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces useable by other services.

### Example

## Run transmission-daemon inside a network namespace

Write the following into "/etc/netns_helper/ns/torrents.conf":

```sh
MAC=<enter a mac address>
PARENT_IF=<enter name of the network interface of the host>
```

Edit transmission-daemon service:

```sh
sudo systemctl edit transmission-daemon.service
```

And enter the following:

```
[Unit]
After=netns_helper-macvlan@torrents.service netns_helper-dhcp@torrents.service
Requires=netns_helper-macvlan@torrents.service netns_helper-dhcp@torrents.service

[Service]
NetworkNamespacePath=%t/netns/torrents
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart transmission-daemon.service
```

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations.

### IPv6

A macvlan interface can be configured with an IPv6 address by adding the following inside the namespace configuration file "/etc/netns_helper/ns/<namespace>.conf":

```sh
IPADDR6=<enter IPv6 address>
```

DHCP isn't supported at the moment for IPv6 because from my testing, all macvlan are getting the same DUID which of course will not work for giving them unique addresses. The same problem arise with other solutions such as firejail.
