# frozen_string_literal: true

require 'spec_helper'

describe 'serial port facts' do
  let(:kernel) { 'Linux' }

  before do
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return(kernel)
  end

  after { Facter.clear }

  def stub_driver(path, content)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(path).and_return(!content.nil?)
    allow(File).to receive(:foreach).and_call_original
    allow(File).to receive(:foreach).with(path).and_return(content.each_line) unless content.nil?
  end

  describe 'serialports' do
    subject(:fact) { Facter.fact(:serialports).value }

    context 'with UARTs present' do
      before do
        stub_driver('/proc/tty/driver/serial', <<~SERIAL)
          serinfo:1.0 driver revision:
          0: uart:16550A port:000003F8 irq:4 tx:0 rx:0
          1: uart:16550A port:000002F8 irq:3 tx:6574 rx:0 RTS|DTR
          2: uart:unknown port:000003E8 irq:4
          3: uart:unknown port:000002E8 irq:3
        SERIAL
      end

      it { is_expected.to eq(%w[ttyS0 ttyS1]) }
    end

    context 'without the serial driver' do
      before { stub_driver('/proc/tty/driver/serial', nil) }

      it { is_expected.to eq([]) }
    end

    context 'when not on Linux' do
      let(:kernel) { 'Darwin' }

      it { is_expected.to be_nil }
    end
  end

  describe 'usbserialports' do
    subject(:fact) { Facter.fact(:usbserialports).value }

    context 'with USB serial devices present' do
      before do
        stub_driver('/proc/tty/driver/usbserial', <<~USBSERIAL)
          usbserinfo:1.0 driver:2.0
          0: module:usb_serial_simple name:"suunto" vendor:0fcf product:1008 num_ports:1 port:0 path:usb-0000:00:1a.0-1.1.1.2
          1: module:pl2303 name:"pl2303" vendor:0557 product:2008 num_ports:1 port:0 path:usb-0000:00:1a.0-1.1.1.3
        USBSERIAL
      end

      it { is_expected.to eq(%w[ttyUSB0 ttyUSB1]) }
    end

    context 'without the usbserial driver' do
      before { stub_driver('/proc/tty/driver/usbserial', nil) }

      it { is_expected.to eq([]) }
    end

    context 'when not on Linux' do
      let(:kernel) { 'Darwin' }

      it { is_expected.to be_nil }
    end
  end
end
