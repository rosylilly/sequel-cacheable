# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module ClassMethods
      attr_reader :cache_driver, :cache_options, :caches

      def inherited(subclass)
        super
      end

      def primary_key_lookup(id)
        cache_fetch(id.to_s) do
          super
        end
      end

      def restore_by_cache(hash)
        return nil if hash.nil?

        return hash.map{|hs| restore_by_cache(hs) } if hash.is_a?(Array)

        return hash if hash.kind_of?(Sequel::Model)

        hash.keys.each do | key |
          value = hash.delete(key)
          key = key.to_sym rescue key
          case db_schema[key][:type]
          when :date
            value = Date.new(*value)
          when :time
            value = Sequel::SQLTime.at(value[0], value[1])
          when :datetime
            value = Time.at(value[0], value[1])
          when :decimal
            value = BigDecimal.new(value)
          when :integer
            value = value.to_i
          end
          hash[key] = value
        end

        return new(hash, true)
      end

      def cache_key(key)
        "#{self.name}:#{key}"
      end

      def cache_set(key, value, ttl = @cache_options[:ttl])
        @caches[key.match(/\AQuery:/) ? :query : :instance] << key
        cache_driver.set(cache_key(key), value, ttl)
      end

      def cache_get(key)
        restore_by_cache(cache_driver.get(cache_key(key)))
      end

      def cache_fetch(key, ttl = @cache_options[:ttl], &block)
        @caches[key.match(/\AQuery:/) ? :query : :instance] << key
        cache_driver.fetch(cache_key(key), ttl, &block)
      end

      def cache_del(key)
        @caches[key.match(/\AQuery:/) ? :query : :instance].delete(key)
        cache_driver.del(cache_key(key))
      end

      def cache_clear(type)
        @caches[type].dup.each {|key| cache_del(key) }
      end
    end
  end
end
