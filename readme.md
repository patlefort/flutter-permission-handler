netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces usable by other services or applications.

## Example

### Run transmission-daemon inside a network namespace

Enable network namespace services and add transmission-daemon service to namespace:

```sh
sudo netns-helper enable torrents macvlan dhcpcd dnsmasq --parent_if <interface> --now
sudo netns-helper add-service transmission-daemon torrents --now
```

**Read the DNS section in the manual to make sure name resolution is working properly.**

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations.

## Installation

On Arch Linux, simply install package `netns-helper-git` from the AUR.

For manually installing, the usual cmake commands:

```sh
cmake <source path>
cmake --build .
cmake --install .
```

## Documentation

See manual pages (netns-helper, netns-helper-config).
