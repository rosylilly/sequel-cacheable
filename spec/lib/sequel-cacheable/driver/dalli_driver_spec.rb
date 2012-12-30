require 'spec_helper'

describe Sequel::Plugins::Cacheable::DalliDriver do
  let(:store) { DalliCli }

  include_examples :driver
end

