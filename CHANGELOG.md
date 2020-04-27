
## 2020-04-27 - Release 1.0.1

- Changed reboot default to false

## 2020-04-27 - Release 1.0.0

- Remove old OS support so only grub2 needs to be supported
- Massive simplification
- Reboot if kernel parameters changed, can be disabled with `reboot => false`
- Allow removal with `ensure => absent`

## 2019-03-28 - Release 0.10.0

- Forked from https://github.com/CERIT-SC/puppet-serial_console
- Support Ubuntu 18.04
- Convert to PDK

## 2017-10-31 - Release 0.9.11

- Support Debian 9

## 2017-08-02 - Release 0.9.10

- Fix unupdated class serial_console::kernel::grubby

## 2017-07-21 - Release 0.9.9

- Fix autologout script template variable reference

## 2017-05-31 - Release 0.9.8

- Fix typos, quoting
- Classes calls simplifications

## 2015-09-15 - Release 0.9.7

### Summary

Debian 8 and Puppet 4.x support. Facts as lists. Cleanups.

#### Features

- Support for new Debian 8 and updates for Puppet 4.x
- Support for getty terminal type

#### Bugfixes

- Better parameters validation
- Code cleanups

## 2015-03-02 - Release 0.9.6

### Summary

Fix unquoted substitutions in /etc/default/grub.

#### Bugfixes

- Fix unquoted substitutions in /etc/default/grub
  to prevent Augeas parse errors.

## 2015-03-02 - Release 0.9.5

### Summary

Change GRUB2 manipulation to kernel_parameter{}, allow to specify
non-serial tty console output, code refactoring. Fix device names
in $::usbserialports.

#### Features

- Change work with GRUB2 from augeas{} to kernel_parameter{}
- New option ($tty) to specify kernel console output to tty

#### Bugfixes

- Fix device names in fact $::usbserialports

## 2014-12-08 - Release 0.9.3

### Summary

Fix file/directory permissions.

#### Bugfixes

- Fix PF module archive file/directory permissions.

## 2014-10-02 - Release 0.9.2

### Summary

Remove deprecation warning on ERB

#### Bugfixes

- Remove deprevation warning from ERB

## 2014-09-02 - Release 0.9.1

### Summary

Fix metadata.json

#### Bugfixes

- Fix metadata.json module dependencies

## 2014-08-28 - Release 0.9.0

### Summary

Initial release.
