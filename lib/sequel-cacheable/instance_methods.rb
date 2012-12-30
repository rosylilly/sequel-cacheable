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
        cache! unless id.nil?
        super
      end

      def after_update
        recache!
        super
      end

      def before_destroy
        uncache!
        super
      end

      def delete
        uncache!
        super
      end

      def cache!
        model.cache_set(cache_key, self)
      end

      def uncache!
        model.cache_del(cache_key)
        model.clear_query_cache
      end

      def recache!
        uncache!
        cache!
      end

      def cache_key
        "#{self.id.to_s}"
      end
    end
  end
end
