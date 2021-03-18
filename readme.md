netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces usable by other services.

### Example

## Run transmission-daemon inside a network namespace

Create a file in `/etc/netns/torrents/resolv.conf`:

```sh
sudo mkdir -p /etc/netns/torrents
sudo touch /etc/netns/torrents/resolv.conf
```

If your `/etc/nsswitch.conf` contains `resolve` or `resolve [!UNAVAIL=return]`:

```sh
sudo cp /etc/nsswitch.conf /etc/netns/torrents/nsswitch.conf
```

Then modify `/etc/netns/torrents/nsswitch.conf` to remove `resolve` and put `dns` of not already present.

Write the following into `/etc/netns-helper/ns/torrents.conf`:

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
After=netns-helper-macvlan@torrents.service netns-helper-dhcp@torrents.service
Requires=netns-helper-macvlan@torrents.service netns-helper-dhcp@torrents.service

[Service]
NetworkNamespacePath=%t/netns/torrents
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart transmission-daemon.service
```

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations. You can add `netns-helper-dhcp6@torrents.service` to `After=` and `Requires=` if you want to use DHCPv6.
