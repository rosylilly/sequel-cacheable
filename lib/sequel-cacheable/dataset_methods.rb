# coding: utf-8

module Sequel::Plugins
  module Cacheable
    module DatasetMethods
      def all(*args, &block)
        if(
          model &&
          model.respond_to?(:cache_fetch) &&
          model.cache_options[:query_cache] &&
          @row_proc.kind_of?(Class) &&
          @row_proc.included_modules.include?(Sequel::Model::InstanceMethods)
        )
          @row_proc.cache_fetch(cache_key) do
            super(*args, &block)
          end
        else
          super(*args, &block)
        end
      end

      def first(*args)
        if(
          model &&
          model.respond_to?(:cache_fetch) &&
          model.cache_options[:query_cache] &&
          @row_proc.kind_of?(Class) &&
          @row_proc.included_modules.include?(Sequel::Model::InstanceMethods)
        )
          @row_proc.cache_fetch("#{cache_key}:first") do
            super(*args)
          end
        else
          super(*args)
        end
      end

      def with_pk(pk)
        if pk.is_a(Integer)
          model.cache_fetch(pk.to_s) do
            super(pk)
          end
        else
          super(pk)
        end
      end

      def cache_key
        "Query:#{select_sql.gsub(/ +/, '_')}"
      end
    end
  end
end
