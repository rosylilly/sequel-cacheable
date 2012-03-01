require 'sequel'
require 'hashr'
require 'msgpack'

module Sequel::Plugins
  module Cacheable
    def self.configure(model, store, options = {})
      model.instance_eval do
        @cache_store = store
        @cache_store_type = Hashr.new({
          :set_with_ttl => store.respond_to?(:set) ? store.method(:set).arity != 2 : false,
          :delete_method => (
            (store.respond_to?(:del) && :del) ||
            (store.respond_to?(:delete) && :delete) ||
            (raise NoMethodError, "#{store.class} is not implemented delete method")
          )
        })
        @cache_options = Hashr.new(options, {
          :ttl => 3600,
          :ignore_exception => false,
          :pack_lib => MessagePack,
          :query_cache => store.respond_to?(:keys)
        })
      end
    end

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
          obj = restore_cache(cache_options.pack_lib.unpack(obj))
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

    module DatasetMethods
      def all(*args)
        if model.cache_options.query_cache? && @row_proc.kind_of?(Class) && @row_proc.included_modules.include?(Sequel::Model::InstanceMethods)
          @row_proc.cache_set_get(query_to_cache_key) { super(*args) }
        else
          super(*args)
        end
      end

      def first(*args)
        if model.cache_options.query_cache? && @row_proc.kind_of?(Class) && @row_proc.included_modules.include?(Sequel::Model::InstanceMethods)
          @row_proc.cache_set_get(query_to_cache_key) { super(*args) }
        else
          super(*args)
        end
      end

      def query_to_cache_key
        model.name + '::Query::' + select_sql.gsub(/ /, '_')
      end
    end
  end
end
