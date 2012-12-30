# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module ClassMethods
      attr_reader :cache_driver, :cache_options

      def inherited(subclass)
        super
      end

      def primary_key_lookup(id)
        cache_fetch(id.to_s) do
          super
        end
      end

      def cache_key(key)
        @caches[key.match(/\AQuery:/) ? :query : :instance] << key
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
        cache_driver.del(cache_key(key))
      end

      def cache_clear(type)
        @caches[type].dup.each {|key| cache_del(key) }
      end
    end
  end
end
