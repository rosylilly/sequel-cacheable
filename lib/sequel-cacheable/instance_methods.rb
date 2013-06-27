# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module InstanceMethods
      def after_initialize
        super
        cache! unless id.nil?
      end

      def after_save
        super
        recache!
      end

      def delete(*args)
        uncache!
        super
      end

      def destroy(*args)
        uncache!
        super(*args)
      end

      def cache!
        model.cache_set(cache_key, self)
      end

      def uncache!
        model.cache_del(cache_key)
        model.cache_clear(:query)
      end

      def recache!
        uncache!
        cache!
      end

      def cache_key
        "#{self.id.to_s}"
      end

      def to_msgpack(*args)
        msgpack_hash.to_msgpack
      end

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
      private :msgpack_hash
    end
  end
end
