require 'sequel'
require 'msgpack'

require 'sequel-cacheable/version'
require 'sequel-cacheable/driver'
require 'sequel-cacheable/class_methods'
require 'sequel-cacheable/instance_methods'
require 'sequel-cacheable/dataset_methods'

module Sequel::Plugins
  module Cacheable
    def self.configure(model, store, options = {})
      model.instance_eval do
        @cache_driver = Driver.factory(store)
        @cache_options = {
          :ttl => 3600,
          :ignore_exception => false,
          :pack_lib => MessagePack,
          :query_cache => store.respond_to?(:keys)
        }.merge(options)
      end
    end
  end
end
