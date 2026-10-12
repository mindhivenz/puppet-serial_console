class serial_console (
  Enum[present, absent] $ensure          = present,
  Boolean $enable_kernel                 = true,
  Boolean $enable_bootloader             = true,
  Boolean $reboot                        = false,
  Integer $speed                         = 115200,
  Pattern[/^tty(\d+)$/] $tty             = 'tty0',
  Optional[Pattern[/^ttyS(\d+)$/]] $ttys = $facts.dig('serialports', -1),
  Optional[Integer] $logout_timeout      = undef,
) {
  $serialports = $facts['serialports'].lest || { [] }

  if $ensure == present and !$ttys {
    notice("No ttys set for serial_console, ttys found: ${serialports}")
  } elsif $ensure == present and !($ttys in $serialports) {
    err("Invalid serial port '${ttys}'")
  } else {
    $kernel_ensure = $enable_kernel ? {
      true  => $ensure,
      false => absent,
    }
    $bootloader_ensure = $enable_bootloader ? {
      true  => $ensure,
      false => absent,
    }
    $autologout_ensure = ($ensure == present and $logout_timeout) ? {
      true  => file,
      false => absent,
    }
    $console = $ttys.then |$port| { [$tty, "${port},${speed}"] }
    $serial_command = $ttys.then |$port| { "serial --unit=${regsubst($port, '^ttyS', '')} --speed=${speed}" }
    $autologout_script = $logout_timeout.then |$timeout| { epp('serial_console/ttyS_autologout.sh.epp', { timeout => $timeout }) }

    kernel_parameter { 'console':
      ensure => $kernel_ensure,
      value  => $console,
    }
    grub_config { 'GRUB_TERMINAL':
      ensure => $bootloader_ensure,
      value  => 'console serial',
    }
    grub_config { 'GRUB_SERIAL_COMMAND':
      ensure => $bootloader_ensure,
      value  => $serial_command,
    }
    file { '/etc/profile.d/ttyS_autologout.sh':
      ensure  => $autologout_ensure,
      content => $autologout_script,
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
