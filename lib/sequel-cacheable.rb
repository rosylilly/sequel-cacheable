require 'sequel'
require 'msgpack'

require 'sequel-cacheable/version'
require 'sequel-cacheable/packer'
require 'sequel-cacheable/driver'
require 'sequel-cacheable/class_methods'
require 'sequel-cacheable/instance_methods'
require 'sequel-cacheable/dataset_methods'

module Sequel::Plugins
  module Cacheable
    def self.configure(model, store, options = {})
      model.instance_eval do
        @cache_options = {
          :ttl => 3600,
          :pack_lib => MessagePack,
          :query_cache => false
        }.merge(options)
        @cache_driver = Driver.factory(
          store,
          Packer.factory(@cache_options[:pack_lib])
        )
        @caches = {
          :instance => [],
          :query => []
        }
      end
    end
  end
end
