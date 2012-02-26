require 'spec_helper'

class RedisModel < Sequel::Model(:spec)
end

class MemcacheModel < Sequel::Model(:spec)
  plugin :cacheable, MemcacheCli
end

QueenCheck::Arbitrary(Float, Fixnum.arbitrary.gen)
QueenCheck::Arbitrary(String, QueenCheck::Gen.quadratic(200).bind { | length |
    if length.zero?
      QueenCheck::Gen.unit("")
    else
      QueenCheck::Gen.rand.resize(1, length).fmap { | r |
        str = []
        r.times { str << QueenCheck::Alphabet.arbitrary.gen.value(0)[0] }
        str.join()
      }
    end
  })

describe Sequel::Plugins::Cacheable do
  QueenCheck("Generate Test Datas",
  String, Fixnum, Float) do |string, fixnum, float|
    float = float * 1.0 / (10 ** (rand(4) + 1))
    RedisModel.create({
      :string => string,
      :int => fixnum,
      :float => float,
      :time => Time.now
    })
    true
  end

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
        MemcacheModel.cache_set('MemcacheModel::test', MemcacheModel[1])
      end

      it "get" do
        MemcacheModel.cache_get('MemcacheModel::test').should == MemcacheModel[1]
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
        RedisModel.cache_set('RedisModel::test', RedisModel[1])
      end

      it "get" do
        RedisModel.cache_get('RedisModel::test').should == RedisModel[1]
      end

      it "del" do
        RedisModel.cache_del('RedisModel::test')
        RedisModel.cache_get('RedisModel::test').should be_nil
      end
    end

    describe "act as cache" do
      it "Model[1]" do
        obj = RedisModel[2]
        p obj
      end
    end
  end
end
