require 'spec_helper'

describe 'serial_console' do
  context 'with ports found' do
    let(:facts) do
      {
        'serialports' => ['ttyS0', 'ttyS1'],
      }
    end

    context 'Happy day' do
      it do
        is_expected.to compile
        is_expected.to contain_kernel_parameter('console')
        is_expected.to contain_grub_config('GRUB_TERMINAL')
        is_expected.to contain_grub_config('GRUB_SERIAL_COMMAND')
      end
    end

    context 'Absent' do
      let(:params) do
        {
          'ensure' => 'absent',
        }
      end

      it do
        is_expected.to compile
      end
    end
  end
  context 'without ports found' do
    let(:facts) do
      {
        'serialports' => [],
      }
    end

    context 'Happy day' do
      it do
        is_expected.to compile
        is_expected.not_to contain_kernel_parameter('console')
        is_expected.not_to contain_grub_config('GRUB_TERMINAL')
        is_expected.not_to contain_grub_config('GRUB_SERIAL_COMMAND')
      end
    end

    context 'Absent' do
      let(:params) do
        {
          'ensure' => 'absent',
        }
      end

      it do
        is_expected.to compile
      end
    end
  end
end
