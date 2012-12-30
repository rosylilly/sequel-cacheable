# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module InstanceMethods
      def msgpack_hash
        hash = {}
        @values.each_pair do | key, value |
          case value
          when Date
            value = [value.year, value.mon, value.mday, value.start]
          when Sequel::SQLTime, Time
            value = [value.to_i, value.usec]
          when BigDecimal, Bignum
            value = value.to_s
          end
          hash[key] = value
        end
        hash
      end

      def to_msgpack(*args)
        msgpack_hash.to_msgpack
      end

      def after_initialize
        store_cache unless id.nil?
        super
      end

      def after_update
        restore_cache
        super
      end

      def delete
        delete_cache
        super
      end

      def destroy(*args)
        delete_cache
        super(*args)
      end

      def store_cache
        model.cache_set(cache_key, self)
      end

      def delete_cache
        model.cache_del(cache_key)
        model.clear_query_cache
      end

      def restore_cache
        delete_cache
        store_cache
      end

      def cache_key
        "#{self.class.name}::#{self.id.to_s}"
      end
    end
  end
end
