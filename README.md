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

The module is managed with [jig](https://github.com/voxpupuli/jig). Validation and unit tests run inside the [VoxBox](https://github.com/voxpupuli/container-voxbox) container, so the only host requirements are jig and Docker (or Podman).

### Setup

Install jig from its [releases](https://github.com/voxpupuli/jig/releases), then point its runner at the same VoxBox image CI uses (see `VOXBOX_IMAGE` in `.github/workflows/ci.yml`):

```shell
export JIG_RUNNER_TYPE=voxbox
export JIG_RUNNER_IMAGE=ghcr.io/voxpupuli/voxbox:10.1.0-openvox8.30.0@sha256:01bb8ce5e24d5b111934660f75e2786b4d7c7adcaa7518a564856d1d3041d10d
```

To make this permanent, put the equivalent `[runner]` section in your jig config file instead (see the [jig voxbox docs](https://github.com/voxpupuli/jig/blob/main/docs/voxbox.md)).

### Validate and test

```shell
jig validate     # syntax, puppet-lint and rubocop
jig test unit    # rspec-puppet unit tests
```

Run a single spec file by calling the container directly:

```shell
docker run --rm -v "$PWD:/repo" -e SPEC=spec/classes/serial_console_spec.rb "$JIG_RUNNER_IMAGE" spec
```

### Build

```shell
jig build
```

The package is written to `pkg/`. Which files are packaged is controlled by the `[build]` section of `jig.toml`.

## Contributors

* Steven Bakker <steven.bakker@ams-ix.net>
* Matthew Rásó-Barnett <matthewrasobarnett@gmail.com>
* Damon Maria <damon@mindhive.co.nz>
