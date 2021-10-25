netns-helper
==============================

netns-helper provides some systemd services to help with the creation of network namespaces usable by other services or applications.

## Example

### Run transmission-daemon inside a network namespace

Enable network namespace services and add transmission-daemon service to namespace:

```sh
sudo netns-helper enable torrents macvlan dhcp --parent_if <interface> --now
sudo netns-helper add-service transmission-daemon torrents --now
```

**Read the DNS section in the manual to make sure name resolution is working properly.**

transmission-daemon will then run inside the network namespace "torrents" with a macvlan interface configured via dhcp. It will basically run with its own MAC address and IP address like a separate machine on your network, with the exception of some macvlan limitations. You can enable DHCPv6 with `sudo netns-helper enable torrents dhcp6 --now`.

## Installation

On Arch Linux, simply install package `netns-helper-git` from the AUR. For manually installing, you can use the `install.sh` script. Run as sudo, specify the prefix with PREFIX environment variable (default to `/usr/local`). This will not install the manual pages. You can generate manual pages with command `xsltproc 'http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl' man/manual.xml`. This will generate man pages in the current directory. Then move the generated man files into `$PREFIX/share/man/man1`.

## Documentation

See manual pages (netns-helper, netns-helper-config, netns-helper-services).