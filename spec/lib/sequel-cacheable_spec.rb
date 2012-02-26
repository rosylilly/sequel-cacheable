require 'spec_helper'

class RedisModel < Sequel::Model(:spec)
end

class MemcacheModel < Sequel::Model(:spec)
  plugin :cacheable, MemcacheCli
end

describe Sequel::Plugins::Cacheable do
  context "NoNameClass" do
    before {
      @model = Class.new(Sequel::Model(:rspec))
    }

    it "should raise NoMethodError if the delete method is not found" do 
      proc {
        @model.plugin :cacheable, 1
      }.should raise_error(NoMethodError)
    end
  end

  context MemcacheModel do
    subject { MemcacheModel }

    its("cache_store") { should == MemcacheCli }
    its("cache_store_type.set_with_ttl?") { should be_true }
    its("cache_store_type.delete_method") { should == :delete }
    its("cache_options.ttl") { should == 3600 }
    its("cache_options.ignore_exceptions") { should be_false }
    its("cache_options.pack_lib") { should == MessagePack }

    describe "cache control" do
      it "set" do
        MemcacheModel.cache_set('MemcacheModel::test', 'string')
      end

      it "get" do
        MemcacheModel.cache_get('MemcacheModel::test').should == 'string'
      end

      it "del" do
        MemcacheModel.cache_del('MemcacheModel::test')
        MemcacheModel.cache_get('MemcacheModel::test').should be_nil
      end
    end
  end

  context RedisModel do
    subject { RedisModel }

    it "should raise LoadError if the plugin is not found" do
      proc{ RedisModel.plugin :something_or_other}.should raise_error(LoadError)
    end

    its("columns") { should == [:id, :string, :int, :float, :time]}

    its("plugins") {
      should_not include(Sequel::Plugins::Cacheable)
      RedisModel.plugin :cacheable, RedisCli
      should include(Sequel::Plugins::Cacheable)
    }

    its("cache_store") { should == RedisCli }
    its("cache_store_type.set_with_ttl?") { should be_false }
    its("cache_store_type.delete_method") { should == :del }
    its("cache_options.ttl") { should == 3600 }
    its("cache_options.ignore_exceptions") { should be_false }
    its("cache_options.pack_lib") { should == MessagePack }

    describe "cache control" do
      it "set" do
        RedisModel.cache_set('RedisModel::test', 'string')
      end

      it "get" do
        RedisModel.cache_get('RedisModel::test').should == 'string'
      end

      it "del" do
        RedisModel.cache_del('RedisModel::test')
        RedisModel.cache_get('RedisModel::test').should be_nil
      end
    end
  end
end
