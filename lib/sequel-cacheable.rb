require 'sequel'
require 'hashr'

module Sequel::Plugins
  module Cacheable
    def self.configure(model, store, options = {})
      model.instance_eval do
        @cache_store = store
        @cache_store_type = Hashr.new({
          :set_with_ttl => store.method(:set).arity != 2
        })
        @cache_options = Hashr.new(options, {
          :ttl => 3600,
          :ignore_exception => false
        })
      end
    end

    module ClassMethods
      attr_reader :cache_store
      attr_reader :cache_store_type
      attr_reader :cache_options
    end
  end
end
