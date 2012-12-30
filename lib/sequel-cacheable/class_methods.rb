# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module ClassMethods
      attr_reader :cache_store
      attr_reader :cache_store_type
      attr_reader :cache_options

      def inherited(subclass)
        super
        cache = [@cache_store, @cache_store_type, @cache_options]
        subclass.instance_eval do
          @cache_store = cache[0]
          @cache_store_type = cache[1]
          @cache_options = cache[2]
        end
      end

      def cache_set(key, obj, ttl = nil)
        return obj if obj.nil?

        ttl = ttl || cache_options.ttl
        if cache_options.pack_lib?
          obj = obj.map{|o| o.id } if obj.kind_of?(Array)
          obj = cache_options.pack_lib.pack(obj)
        end

        args = [key, obj]
        args << ttl if cache_store_type.set_with_ttl?
        cache_store.set(*args)
        unless cache_store_type.set_with_ttl?
          cache_store.expire(key, ttl)
        end
      end

      def cache_get(key)
        if cache_options.ignore_exceptions?
          obj = cache_store.get(key) rescue nil
        else
          obj = cache_store.get(key)
        end

        if obj && cache_options.pack_lib?
          begin
            obj = restore_cache(cache_options.pack_lib.unpack(obj))
          rescue EOFError
            obj = nil
          end
        end

        obj
      end

      def cache_mget(*keys)
        if cache_options.ignore_exceptions?
          objs = cache_store.mget(*keys) rescue nil
        else
          objs = cache_store.mget(*keys)
        end

        if objs && cache_options.pack_lib?
          objs.map!{|obj|
            key = keys.shift
            (obj && restore_cache(cache_options.pack_lib.unpack(obj))) ||
              model[key.sub(/^#{model}::/, '')]
          }
        end

        objs || []
      end

      def cache_del(key)
        cache_store.send(cache_store_type.delete_method, key)
      end

      def cache_set_get(key, ttl = nil)
        if (val = cache_get(key)).nil?
          val = yield
          cache_set(key, val, ttl)
        end
        val
      end

      def restore_cache(object)
        return object if object.nil?

        return cache_mget(*object.map{|id| "#{model}::#{id}" }) if object.kind_of?(Array)

        object.keys.each do | key |
          value = object.delete(key)
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
          object[key] = value
        end
        new(object, true)
      end

      def clear_query_cache
        return unless cache_options.query_cache?
        cache_store.keys("#{model.name}::Query::*").each do | key |
          cache_del(key)
        end
      end

      def primary_key_lookup(key)
        cache_set_get("#{model}::#{key}") do
          super(key)
        end
      end
    end
  end
end
