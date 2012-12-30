require 'spec_helper'

describe Sequel::Plugins::Cacheable::Driver do
  let(:store) { RedisCli }

  include_examples :driver

  describe '.factory' do
    subject { described_class.factory(store) }

    context 'when Memcache' do
      let(:store) { MemcacheCli }

      it { should be_a(Sequel::Plugins::Cacheable::MemcacheDriver) }
    end

    context 'when Dalli' do
      let(:store) { DalliCli }

      it { should be_a(Sequel::Plugins::Cacheable::DalliDriver) }
    end

    context 'when Redis' do
      let(:store) { RedisCli }

      it { should be_a(Sequel::Plugins::Cacheable::RedisDriver) }
    end

    context 'when Unkown Store' do
      let(:store) { mock }

      it { should be_a(Sequel::Plugins::Cacheable::Driver) }
    end
  end
end
