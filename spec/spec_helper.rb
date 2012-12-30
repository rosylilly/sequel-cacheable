require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
    DB = Sequel.sqlite
    DB.create_table(:spec) do
      primary_key :id, :auto_increment => true
      String :string
      Integer :integer
      Float :float
      Bignum :bignum
      BigDecimal :numeric
      Date :date
      DateTime :datetime
      Time :time, :only_time=>true
      TrueClass :bool
    end
  end

  RedisCli = Redis.new(:host => 'localhost', :port => 6379)
  MemcacheCli = Memcache.new(:server => 'localhost:11211')
  DalliCli = Dalli::Client.new('localhost:11211')

  config.after(:each) do
    RedisCli.flushall
    MemcacheCli.flush_all
    DalliCli.flush_all
  end
end
