require 'spec_helper'

describe 'serial_console' do
  let(:facts) do
    {
      'serialports' => %w[ttyS0 ttyS1],
    }
  end

  context 'Happy day' do
    it do
      is_expected.to compile
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
