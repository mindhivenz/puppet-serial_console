class serial_console (
  Enum[present, absent] $ensure        = present,
  Boolean $enable_kernel               = true,
  Boolean $enable_bootloader           = true,
  Optional[Pattern[/^tty(\d+)$/]] $tty = 'tty0',
  Pattern[/^ttyS(\d+)$/] $ttys         = $facts['serialports'][-1],
  Integer $speed                       = 115200,
  Optional[Integer] $logout_timeout    = undef,
  Optional[String] $cmd_refresh_kernel = "/bin/systemctl restart serial-getty@${$ttys}.service",
) {

  if !($ttys in $facts['serialports']) {
    err("Invalid serial port '${ttys}'")
  } else {

    kernel_parameter { 'console':
      ensure => if $enable_kernel { $ensure } else { 'absent' },
      value  => if $tty { [$tty] } else { [] } + ["${ttys},${speed}"],
    }

    unless empty($cmd_refresh_kernel) {
      exec { 'serial_console-refresh-kernel':
        command     => $cmd_refresh_kernel,
        refreshonly => true,
        subscribe   => Kernel_parameter['console'],
      }
    }

    $_ttys_id = regsubst($ttys, '^ttyS(\d+)$', '\1')
    grub_config { 'GRUB_TERMINAL':
      ensure => if $enable_bootloader { $ensure } else { 'absent' },
      value  => 'console serial',
    }
    grub_config { 'GRUB_SERIAL_COMMAND':
      ensure => if $enable_bootloader { $ensure } else { 'absent' },
      value  => "serial --unit=${_ttys_id} --speed=${speed}"
    }

    $content = if $logout_timeout {
      epp('serial_console/ttyS_autologout.sh.epp', { timeout => $logout_timeout })
    } else {
      ''
    }
    file { '/etc/profile.d/ttyS_autologout.sh':
      ensure  => if $logout_timeout and $ensure == present { 'file' } else { 'absent' },
      content => $content,
    }

  }

}
