netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces usable by other services.

## Example

### Run transmission-daemon inside a network namespace

Enable network namespace services and add transmission-daemon service to namespace:

```sh
sudo netns-helper enable torrents macvlan dhcp --parent_if <interface> --now
sudo netns-helper add-service transmission-daemon torrents --now
```

**Read the DNS section to make sure name resolution is working properly.**

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations. You can enable DHCPv6 with `sudo netns-helper enable torrents dhcp6 --now`.

## `netns-helper` command

### Switches:

* `--now`: Start, restart or stop services now.
* `--overwrite`: Overwrite config with new config if applicable to feature.
* `--parent_if <interface>`: Parent interface for macvlan.
* `--mac <mac address>`: MAC address of macvlan interface.

### `sudo netns-helper enable <namespace> [<list of features>]`

Enable a namespace. Listed features' service units are enabled as well as the target unit. Features are a whitespace separated list of features from those available (dhcp, dhcp6, macvlan).

### `sudo netns-helper disable <namespace> [<list of features>]`

Disable a namespace. If a list of features is given, only the given features are disabled. Service units that are part of the network namespace will not start while the namespace target unit is disabled.

### `sudo netns-helper add-service <service> <namespace>`

Put a service into a network namespace. This command will create a file in `/etc/systemd/system/<service>.d/netns-helper.conf`. The service will only start if the network namespace target unit is activated.

### `sudo netns-helper remove-service <service>`

Remove service from a network namespace.

### `netns-helper status <namespace>`

Show status of namespace services.

### `sudo netns-helper start|restart|stop <namespace>`

Start/restart/stop network namespace target. Restarting or stopping will also affect services that are part of the namespace.

## Configuration

Namespaces with netns-helper are configured in `/etc/netns-helper/ns`.

### `<namespace>-macvlan.conf`

Configuration for a macvlan interface.

```sh
# Parent interface on host for macvlan interface.
PARENT_IF=

# [Optional] MAC address for macvlan interface. Leave empty to let iproute2 generate one.
#MAC=

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

## Service files

### `netns-helper@.target`

Services for a network namespace are grouped into a target under the namespace's name.

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

## DNS

In order to make name resolution work properly inside the network namespace, some precautions must be taken:

* `netns-helper-dhcp@.service` run dhclient which might overwrite your host's resolv.conf. To avoid this you should create a file `/etc/netns/<namespace>/resolv.conf`. If you are using systemd-resolved and your `/etc/resolv.conf` is a symlink, you will have to remove it, recreate it as a regular file and explicitly tell your network manager of your host to use systemd-resolved and to stop managing `resolv.conf`. If you are using NetworkManager, you can add the following file into `/etc/NetworkManager/conf.d/00-dns-resolved.conf`:

```
[main]
dns=none
systemd-resolved=true
```

Then make sure your `/etc/nsswitch.conf` contain `resolve` in he `hosts:` line. Remove `dns` if present. Also make sure that you have installed `nss-resolve` on your system.

* Make sure your network namespace is not using your host's systemd-resolved. If your `/etc/nsswitch.conf` contains `resolve` or `resolve [!UNAVAIL=return]`, it will be used via dbus.

```sh
sudo cp /etc/nsswitch.conf /etc/netns/<namespace>/nsswitch.conf
```

Then modify `/etc/netns/<namespace>/nsswitch.conf` to remove `resolve` and put `dns` of not already present.
