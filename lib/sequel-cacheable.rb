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
          :pack_lib => MessagePack
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
        ttl = ttl || cache_options.ttl
        if cache_options.pack_lib?
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
          obj = cache_options.pack_lib.unpack(obj)
        end
      end

      def cache_del(key)
        cache_store.send(cache_store_type.delete_method, key)
        nil
      end
    end
  end
end
