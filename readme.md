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

If you are using systemd-resolved and your `/etc/resolv.conf` is a symlink, you will have to remove it, recreate it as a regular file and explicitly tell your network manager to use systemd-resolved. If you are using NetworkManager, you can add the following file into `/etc/NetworkManager/conf.d/00-dns-resolved.conf`:
```
[main]
dns=systemd-resolved
```

Leaving it a symlink will cause your host's resolv.conf to be overwritten by dhclient inside the network namespace.

If the `netns-dhclient-script-wrapper` script is installed elsewhere than `/usr/bin`, you will have to edit `netns-helper-dhcp@.service` and `netns-helper-dhcp6@.service` (if you use dhcpv6):

```sh
sudo systemctl edit netns-helper-dhcp@.service
```

Enter the following:
```
[Service]
Environment=DHCLIENT_SCRIPT_WRAPPER=<enter path to netns-dhclient-script-wrapper>
```

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
JoinsNamespaceOf=netns-helper@torrents.service
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart transmission-daemon.service
```

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations. You can add `netns-helper-dhcp6@torrents.service` to `After=` and `Requires=` if you want to use DHCPv6.
