netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces usable by other services.

## Service files

### `netns-helper@.service`

Create a network namespace. Services should either use `JoinsNamespaceOf=` or use ip command `ip netns exec <namespace>` to execute inside the network namespace. Services should also bind to the following files if present:

```
BindPaths=-/etc/netns/<namespace>/resolv.conf:/etc/resolv.conf
BindPaths=-/etc/netns/<namespace>/nsswitch.conf:/etc/nsswitch.conf
```

### `netns-helper-macvlan@.service`

Create a macvlan interface inside the network namespace, bridged with an interface on host defined in `/etc/netns-helper/ns/<namespace>-macvlan.conf`. It will execute the following scripts if present and executable, inside the network namespace:

* `/etc/netns-helper/ns/<namespace>-macvlan-preup`: Before the macvlan is set as up.
* `/etc/netns-helper/ns/<namespace>-macvlan-postup`: After the macvlan is set as up and configured.

The first argument passed will be the name of the macvlan interface.

### `netns-helper-dhcp@.service`

Run dhclient in IPv4 mode inside network namespace. If the `netns-dhclient-script-wrapper` script is installed elsewhere than `/usr/bin`, you will have to edit `netns-helper-dhcp@.service` and `netns-helper-dhcp6@.service` (if you use dhcpv6):

```sh
sudo systemctl edit netns-helper-dhcp@.service
```

Enter the following:
```
[Service]
Environment=DHCLIENT_SCRIPT_WRAPPER=<enter path to netns-dhclient-script-wrapper>
```

dhclient will read the file `/etc/netns-helper/ns/<namespace>-dhclient.conf` for its configuration (-cf switch).

### `netns-helper-dhcp6@.service`

Run dhclient in IPv6 mode inside network namespace. dhclient will read the file `/etc/netns-helper/ns/<namespace>-dhclient6.conf` for its configuration (-cf switch).

### `netns-helper-postup@.service`

Executed after all other netns-helper services have started for a network namespace. It will run the script in `/etc/netns-helper/ns/<namespace>-postup` if present and executable. The script run inside the network namespace. You should setup routes and firewall rules there.

## Configuration

Namespaces with netns-helper are configured in `/etc/netns-helper/ns`.

### `<namespace>-macvlan.conf`

```sh
# MAC address for macvlan interface.
MAC=

# Parent interface on host for macvlan interface.
PARENT_IF=

# [Optional] Static IPv4 address
#IPADDR4=

# [Optional] Default IPv4 gateway
#DEFAULT_GATEWAY4=

# [Optional] Static IPv6 address
#IPADDR6=

# [Optional] Default IPv6 gateway
#DEFAULT_GATEWAY6=

# [Optional] Privacy extensions for IPv6. 0, 1 or 2.
# See https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt `use_tempaddr`.
#PRIVACY_EXT=
```

### `<namespace>-postup`

Script executed after all other netns-helper services have started for a network namespace. Must be executable.

## DNS

In order to make name resolution work properly inside the network namespace, some precautions must be taken:

* `netns-helper-dhcp@.service` run dhclient which might overwrite your host's resolv.conf. To avoid this you should create a file `/etc/netns/<namespace>/resolv.conf`. If you are using systemd-resolved and your `/etc/resolv.conf` is a symlink, you will have to remove it, recreate it as a regular file and explicitly tell your network manager of your host to use systemd-resolved. If you are using NetworkManager, you can add the following file into `/etc/NetworkManager/conf.d/00-dns-resolved.conf`:

```
[main]
dns=systemd-resolved
```

Then make sure your `/etc/nsswitch.conf` contain `resolve` in he `hosts:` line.

* Make sure your network namespace is not using your host's systemd-resolved. If your `/etc/nsswitch.conf` contains `resolve` or `resolve [!UNAVAIL=return]`, it will be used via dbus.

```sh
sudo cp /etc/nsswitch.conf /etc/netns/<namespace>/nsswitch.conf
```

Then modify `/etc/netns/<namespace>/nsswitch.conf` to remove `resolve` and put `dns` of not already present.

## Commands

* `sudo netns-helper add <namespace> <service>` to put a service into a network namespace. This command will create a file in `/etc/systemd/system/<service>.d/netns-helper.conf`.
* `sudo netns-helper remove <service>` to remove service from a network namespace.

## Example

### Run transmission-daemon inside a network namespace

Write the following into `/etc/netns-helper/ns/torrents-macvlan.conf`:

```sh
MAC=<enter a mac address>
PARENT_IF=<enter name of the network interface of the host>
```

Enable network namespace services and add transmission-daemon service to namespace:

```sh
sudo systemctl enable --now netns-helper@torrents.service netns-helper-macvlan@torrents.service netns-helper-dhcp@torrents.service
sudo netns-helper add torrents transmission-daemon.service
```

**Read the DNS section to make sure name resolution is working properly.**

```sh
sudo systemctl daemon-reload
sudo systemctl restart transmission-daemon.service
```

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations. You can add `netns-helper-dhcp6@torrents.service` to `Requires=` if you want to use DHCPv6.

