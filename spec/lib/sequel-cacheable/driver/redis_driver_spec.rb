require 'spec_helper'

describe Sequel::Plugins::Cacheable::RedisDriver do
  let(:store) { RedisCli }

  include_examples :driver
end

