# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module DatasetMethods
      def execute(sql, opts = {})
        if(model && model.respond_to?(:cache_fetch))
          model.cache_fetch(sql) do
            super
          end
        else
          super
        end
      end
    end
  end
end
