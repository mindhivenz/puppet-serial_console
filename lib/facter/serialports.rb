# frozen_string_literal: true

Facter.add('serialports') do
  confine kernel: :linux
  setcode do
    driver = '/proc/tty/driver/serial'
    next [] unless File.exist?(driver)

    # Ports the kernel probed but found no UART behind are listed as "uart:unknown"
    File.foreach(driver).filter_map do |line|
      match = line.match(%r{^(?<port>\d+): uart:(?<uart>\w+) })
      "ttyS#{match[:port]}" if match && match[:uart] != 'unknown'
    end
  end
end

Facter.add('usbserialports') do
  confine kernel: :linux
  setcode do
    driver = '/proc/tty/driver/usbserial'
    next [] unless File.exist?(driver)

    File.foreach(driver).filter_map do |line|
      port = line[%r{^(\d+): module:}, 1]
      "ttyUSB#{port}" if port
    end
  end
end
