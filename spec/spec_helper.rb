require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'sequel-cacheable'
require 'redis'
require 'memcache'
require 'queencheck/rspec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
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
  RedisCli = Redis.new(:host => 'localhost', :port => 6379)
  MemcacheCli = Memcache.new(:server => 'localhost:11211')

  config.after(:all) {
    RedisCli.flushall
    MemcacheCli.flush_all
  }
end
