# frozen_string_literal: true

# rspec-puppet caches catalogs, so only the first compile of a given facts and params combination logs.
RSpec.shared_context 'with compile logs' do
  let(:logs) { [] }

  before do
    Puppet::Util::Log.newdestination(Puppet::Test::LogCollector.new(logs))
    # Puppet queues messages logged while it had no destination and flushes them into the first one added.
    logs.clear
  end

  after { Puppet::Util::Log.close_all }

  def messages_at(level)
    logs.select { |log| log.level == level }.map(&:message)
  end
end
