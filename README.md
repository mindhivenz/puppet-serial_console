# Puppet module for system serial console setup

Forked from [CERIT-SC project](https://github.com/CERIT-SC/puppet-serial_console) 
as that seems to be abandoned. 

This module configures system for serial console
access (boot loader, kernel and login)

### Requirements

Module has been tested on:

* Puppet 5.5
* OSes:
    * Ubuntu 18.04
    * Debian 6 - 9
    * RHEL/CentOS 6 - 7

Required modules:

* puppetlabs-stdlib
* herculesteam-augeasproviders\_grub

# Quick Start

Setup

```puppet
include serial_console
```

Full configuration options:

```puppet
class { serial_console:
  ensure                 => present,     # enable configuration
  enable_kernel          => true,        # enable kernel config.
  enable_bootloader      => true,        # enable bootloader config.
  tty                    => 'tty0',      # text console name
  ttys                   => '...',       # serial device name without path, e.g. ttyS0
  speed                  => 115200,      # serial port speed, e.g. 115200
  logout_timeout         => undef,       # interactive session timeout
}
```

# Facts

### serialports, usbserialports

Returns list of available (USB) serial port device names
(without /dev prefix). E.g.:

```
["ttyS0","ttyS1"]
```

# Contributors

* Steven Bakker <steven.bakker@ams-ix.net>
* Matthew Rásó-Barnett <matthewrasobarnett@gmail.com>
* Damon Maria damon@mindhive.co.nz
