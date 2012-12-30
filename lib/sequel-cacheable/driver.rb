module Sequel::Plugins
  module Cacheable
    DRIVERS = %w(memcache dalli redis).freeze

    class Driver
      def self.factory(store)
        case store.name
        when 'Memcache'
          MemcacheDriver.new(store)
        when 'Dalli::Client'
          DalliDriver.new(store)
        when 'Redis'
          RedisDriver.new(store)
        end
      end

      def initialize(store)
        @store = store
      end

      def get(key)
        @store.get(key)
      end

      def set(key, val, expire = nil)
        @store.set(key, val)
      end

      def del(key)
        @store.del(key)
      end
    end
  end
end

Sequel::Plugins::Cacheable::DRIVERS.each do |driver|
  require "sequel-cacheable/driver/#{driver}"
end
