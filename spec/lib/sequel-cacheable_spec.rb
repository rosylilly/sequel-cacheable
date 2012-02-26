require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
      SpecModel.plugin :cacheable
      should include(Sequel::Plugins::Cacheable)
    }
  end
end
