class serial_console (
  Enum[present, absent] $ensure        = present,
  Boolean $enable_kernel               = true,
  Boolean $enable_bootloader           = true,
  Boolean $reboot                      = false,
  Optional[Pattern[/^tty(\d+)$/]] $tty = 'tty0',
  Pattern[/^ttyS(\d+)$/] $ttys         = $facts['serialports'][-1],
  Integer $speed                       = 115200,
  Optional[Integer] $logout_timeout    = undef,
) {

  if !($ttys in $facts['serialports']) {
    err("Invalid serial port '${ttys}'")
  } else {
    $ttys_id = regsubst($ttys, '^ttyS(\d+)$', '\1')

    kernel_parameter { 'console':
      ensure => if $enable_kernel { $ensure } else { 'absent' },
      value  => if $tty { [$tty] } else { [] } + ["${ttys},${speed}"],
    }
    grub_config { 'GRUB_TERMINAL':
      ensure => if $enable_bootloader { $ensure } else { 'absent' },
      value  => 'console serial',
    }
    grub_config { 'GRUB_SERIAL_COMMAND':
      ensure => if $enable_bootloader { $ensure } else { 'absent' },
      value  => "serial --unit=${ttys_id} --speed=${speed}",
    }

    file { '/etc/profile.d/ttyS_autologout.sh':
      ensure  => if $logout_timeout and $ensure == present { 'file' } else { 'absent' },
      content => if $logout_timeout {
        epp('serial_console/ttyS_autologout.sh.epp', { timeout => $logout_timeout })
      } else {
        ''
      },
    }

    if $reboot {
      reboot { 'kernel-params-changed':
        subscribe => [
          Kernel_parameter['console'],
          Grub_config['GRUB_TERMINAL'],
          Grub_config['GRUB_SERIAL_COMMAND'],
        ],
        apply     => finished,
      }
    }

  }

}
