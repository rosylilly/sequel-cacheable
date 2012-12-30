# coding: utf-8

module Sequel::Plugins
  module Cacheable
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
