class serial_console::params {
  $enable = true
  $enable_kernel = true
  $enable_bootloader = true
  $enable_login = true

  # choose last available port
  if length($facts['serialports']) > 1 {
    $ttys = $facts['serialports'][-1]
  } else {
    $ttys = 'ttyS0'
  }

  $tty = 'tty0'
  $speed = 115200
  $term_type = 'vt100'
  $runlevels = '2345'
  $bootloader_timeout = 5
  $logout_timeout = 0

  case $::operatingsystem {
    'RedHat','CentOS','Scientific','SLC','OracleLinux': {
      case $::operatingsystemmajrelease {
        '5','6': {
          $class_kernel = 'grubby'
          $class_bootloader = 'grub1'
          $class_getty = undef
          $cmd_refresh_init = undef
          $cmd_refresh_bootloader = undef
          $cmd_refresh_service = undef
        }

        '7': {
          $class_kernel = 'grub2'
          $class_bootloader = 'grub2'
          $class_getty = undef
          $cmd_refresh_init = undef
          $cmd_refresh_bootloader = undef
          $cmd_refresh_service = undef
        }

        default: {
          fail("Unsupported OS version: ${::operatingsystem} ${::operatingsystemmajrelease}")
        }
      }
    }

    'Debian': {
      case $::operatingsystemmajrelease {
        '6','7': {
          $class_kernel = 'grub2'
          $class_bootloader = 'grub2'
          $class_getty = 'inittab'
          $cmd_refresh_init = '/sbin/telinit q'
          $cmd_refresh_bootloader = '/usr/sbin/update-grub'
          $cmd_refresh_service = undef
        }

        '8','9': {
          $class_kernel = 'grub2'
          $class_bootloader = 'grub2'
          $class_getty = undef
          $cmd_refresh_init = undef
          $cmd_refresh_bootloader = '/usr/sbin/update-grub'
          $cmd_refresh_service = undef
        }

        default: {
          fail("Unsupported OS version: ${::operatingsystem} ${::operatingsystemmajrelease}")
        }
      }
    }

    'Ubuntu': {
      case $::operatingsystemmajrelease {
        '18.04': {
          $class_kernel = 'grub2'
          $class_bootloader = 'grub2'
          $class_getty = undef
          $cmd_refresh_init = undef
          $cmd_refresh_bootloader = '/usr/sbin/update-grub'
          # Just start, don't manage as a service type, as we are not in control of it
          $cmd_refresh_service = "/bin/systemctl start serial-getty@${$ttys}.service"
        }

        default: {
          fail("Unsupported OS version: ${::operatingsystem} ${::operatingsystemmajrelease}")
        }
      }
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
