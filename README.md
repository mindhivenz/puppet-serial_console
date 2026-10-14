# serial_console

Sets up the system serial console, for access through Serial-over-LAN (SOL). It points the kernel console and grub at a serial port by editing `/etc/default/grub` (through [augeasproviders_grub](https://forge.puppet.com/modules/puppet/augeasproviders_grub)).

## Usage

```puppet
include serial_console
```

Full configuration options:

```puppet
class { 'serial_console':
  ensure            => present,  # or absent to remove the configuration
  enable_kernel     => true,     # kernel console= parameter
  enable_bootloader => true,     # grub terminal on the console and serial port
  reboot            => false,    # reboot at the end of the run if the boot config changed (SOL won't work until reboot)
  tty               => 'tty0',   # text console the kernel also writes to
  ttys              => 'ttyS1',  # serial device name without /dev, defaults to the last ttyS* with a UART
  speed             => 115200,   # serial port speed
  logout_timeout    => 600,      # interactive session timeout in seconds on serial ttys (sets TMOUT), default undef (none)
}
```

* `ttys` must be one of the detected `serialports`. If it isn't, nothing is managed and an error is logged. On a host with no serial ports, nothing is managed and a notice is logged. `ensure => absent` removes the configuration whatever the serial ports.
* Disabling `enable_kernel` or `enable_bootloader` removes that part of the configuration.

## Facts

### serialports, usbserialports

Serial (`ttyS*`, only ports with a UART) and USB serial (`ttyUSB*`) device names without the `/dev` prefix, read from `/proc/tty/driver`. For example:

```
["ttyS0","ttyS1"]
```

## Development

See [AGENTS.md](AGENTS.md) for checking changes, the VoxBox gotchas and building. It is shared by every module and synced from [mindhivenz/msync](https://github.com/mindhivenz/msync).

## Contributors

* Steven Bakker <steven.bakker@ams-ix.net>
* Matthew Rásó-Barnett <matthewrasobarnett@gmail.com>
* Damon Maria <damon@mindhive.co.nz>
