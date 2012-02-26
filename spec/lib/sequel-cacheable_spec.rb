require 'spec_helper'

class SpecModel < Sequel::Model(:spec)
end

describe Sequel::Plugins::Cacheable do
  context SpecModel do
    subject { SpecModel }

    it "should raise LoadError if the plugin is not found" do
      proc{ SpecModel.plugin :something_or_other}.should raise_error(LoadError)
    end

    its("columns") { should == [:id, :string, :int, :float, :time]}

    its("plugins") {
      should_not include(Sequel::Plugins::Cacheable)
      SpecModel.plugin :cacheable, RedisCli
      should include(Sequel::Plugins::Cacheable)
    }

    its("cache_store") {
      should == RedisCli
    }

    its("cache_store_type.set_with_ttl?") { should be_false }

    its("cache_options.ttl") { should == 3600 }
    its("cache_options.ignore_exceptions") { should be_false }
  end
end
