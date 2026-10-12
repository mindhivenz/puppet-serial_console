# frozen_string_literal: true

require 'spec_helper'

describe 'serial_console' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(serialports: %w[ttyS0 ttyS1]) }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        it 'puts the kernel console on tty0 and the last serial port' do
          is_expected.to contain_kernel_parameter('console').with(
            ensure: 'present',
            value: ['tty0', 'ttyS1,115200'],
          )
        end

        it 'puts grub on the console and the last serial port' do
          is_expected.to contain_grub_config('GRUB_TERMINAL').with(ensure: 'present', value: 'console serial')
          is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with(
            ensure: 'present',
            value: 'serial --unit=1 --speed=115200',
          )
        end

        it { is_expected.to contain_file('/etc/profile.d/ttyS_autologout.sh').with_ensure('absent') }
        it { is_expected.not_to contain_reboot('kernel-params-changed') }
      end

      context 'with ttys and speed' do
        let(:params) { { ttys: 'ttyS0', speed: 9600 } }

        it { is_expected.to contain_kernel_parameter('console').with_value(['tty0', 'ttyS0,9600']) }
        it { is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with_value('serial --unit=0 --speed=9600') }
      end

      context 'with another text console' do
        let(:params) { { tty: 'tty1' } }

        it { is_expected.to contain_kernel_parameter('console').with_value(['tty1', 'ttyS1,115200']) }
      end

      context 'with the kernel disabled' do
        let(:params) { { enable_kernel: false } }

        it { is_expected.to contain_kernel_parameter('console').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_TERMINAL').with_ensure('present') }
        it { is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with_ensure('present') }
      end

      context 'with the bootloader disabled' do
        let(:params) { { enable_bootloader: false } }

        it { is_expected.to contain_kernel_parameter('console').with_ensure('present') }
        it { is_expected.to contain_grub_config('GRUB_TERMINAL').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with_ensure('absent') }
      end

      context 'with logout_timeout' do
        let(:params) { { logout_timeout: 600 } }

        it 'times out interactive sessions on serial ttys' do
          is_expected.to contain_file('/etc/profile.d/ttyS_autologout.sh').with_ensure('file').with_content(<<~SCRIPT)
            # This file is managed by Puppet!
            if tty | grep -Eq '\\/ttyS[0-9]+$'; then
                export TMOUT="600"
            fi
          SCRIPT
        end
      end

      context 'with reboot' do
        let(:params) { { reboot: true } }

        it 'reboots after the run when the boot config changes' do
          is_expected.to contain_reboot('kernel-params-changed')
            .with_apply('finished')
            .that_subscribes_to(['Kernel_parameter[console]', 'Grub_config[GRUB_TERMINAL]', 'Grub_config[GRUB_SERIAL_COMMAND]'])
        end
      end

      context 'with ensure => absent' do
        let(:params) { { ensure: 'absent', logout_timeout: 600, reboot: true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_kernel_parameter('console').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_TERMINAL').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/profile.d/ttyS_autologout.sh').with_ensure('absent') }
        it { is_expected.to contain_reboot('kernel-params-changed').that_subscribes_to('Kernel_parameter[console]') }
      end

      context 'with ensure => absent without serial ports' do
        let(:facts) { os_facts.merge(serialports: []) }
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_kernel_parameter('console').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_TERMINAL').with_ensure('absent') }
        it { is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/profile.d/ttyS_autologout.sh').with_ensure('absent') }
      end

      context 'with a ttys that is not a detected serial port' do
        include_context 'with compile logs'

        let(:params) { { ttys: 'ttyS5', reboot: true } }

        it 'manages nothing and logs an error' do
          is_expected.to compile.with_all_deps
          is_expected.to have_kernel_parameter_resource_count(0)
          is_expected.to have_grub_config_resource_count(0)
          is_expected.to have_file_resource_count(0)
          is_expected.to have_reboot_resource_count(0)
          expect(messages_at(:err)).to include("Invalid serial port 'ttyS5'")
        end
      end

      context 'with a ttys that is not a serial port name' do
        let(:params) { { ttys: 'ttyUSB0' } }

        it { is_expected.to compile.and_raise_error(%r{ttys}) }
      end

      context 'without serial ports' do
        include_context 'with compile logs'

        let(:facts) { os_facts.merge(serialports: []) }
        let(:params) { { reboot: true } }

        it 'manages nothing and notices instead of erroring' do
          is_expected.to compile.with_all_deps
          is_expected.to have_kernel_parameter_resource_count(0)
          is_expected.to have_grub_config_resource_count(0)
          is_expected.to have_file_resource_count(0)
          is_expected.to have_reboot_resource_count(0)
          expect(messages_at(:err)).to be_empty
          expect(messages_at(:notice)).to include(%r{No ttys set for serial_console})
        end
      end

      context 'without the serialports fact' do
        let(:facts) { os_facts.merge(serialports: nil) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_kernel_parameter_resource_count(0) }

        context 'with ttys' do
          let(:params) { { ttys: 'ttyS0' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to have_kernel_parameter_resource_count(0) }
        end
      end
    end
  end
end
