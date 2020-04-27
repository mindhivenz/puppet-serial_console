# Puppet module for system serial console setup

This module configures system for serial console
access (boot loader and kernel), usable through Serial-over-LAN (SOL).

### Requirements

Module has been tested on:

* Puppet:
    * 5.5
    * 6.14
* OSes:
    * Ubuntu 18.04
    * Debian 8 - 9
    * RHEL/CentOS 7

# Quick Start

Setup

```puppet
include serial_console
```

Full configuration options:

```puppet
class { serial_console:
  ensure            => present,  # add or remove configuration
  enable_kernel     => true,     # enable kernel config
  enable_bootloader => true,     # enable bootloader config
  reboot            => false,    # reboot if kernel parameters are changed (SOL won't work until reboot)
  tty               => 'tty0',   # text console name
  ttys              => 'ttyS0',  # serial device name without path, defaults to last ttyS* with a UART 
  speed             => 115200,   # serial port speed
  logout_timeout    => undef,    # interactive session timeout in seconds (sets TMOUT)
}
```

# Facts

### serialports, usbserialports

List of available serial port device names
(without /dev prefix). For example:

```
["ttyS0","ttyS1"]
```

# Contributors

* Steven Bakker <steven.bakker@ams-ix.net>
* Matthew Rásó-Barnett <matthewrasobarnett@gmail.com>
* Damon Maria damon@mindhive.co.nz
