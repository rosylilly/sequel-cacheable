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
          :pack_lib => MessagePack,
          :query_cache => false
        }.merge(options)
        @caches = {
          :instance => [],
          :query => []
        }
      end
    end
  end
end
