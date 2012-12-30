# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module ClassMethods
      attr_reader :cache_driver, :cache_options

      def inherited(subclass)
        super

        driver = @cache_drvier
        options = @cache_options

        subclass.instance_eval do
          @cache_driver = driver
          @cache_options = options
        end
      end

      def cache_key(key)
        "#{self.name}:#{key}"
      end

      def cache_set(key, value, ttl = @cache_options[:ttl])
        cache_driver.set(cache_key(key), value, ttl)
      end

      def cache_get(key)
        cache_driver.get(cache_key(key))
      end

      def cache_fetch(key, ttl = @cache_options[:ttl], &block)
        cache_driver.fetch(cache_key(key), &block)
      end

      def cache_del(key)
        cache_driver.del(key)
      end
    end
  end
end
