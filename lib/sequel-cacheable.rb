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
  end
end

require 'sequel-cacheable/class_methods'
require 'sequel-cacheable/instance_methods'
require 'sequel-cacheable/dataset_methods'
