require 'spec_helper'

describe Sequel::Plugins::Cacheable::MemcacheDriver do
  let(:store) { MemcacheCli }

  include_examples :driver
end
