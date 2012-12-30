require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

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

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.after(:each) do
    RedisCli.flushall
    MemcacheCli.flush_all
    DalliCli.flush_all
  end

  config.around(:each) do |e|
    DB.transaction do
      e.run
      raise Sequel::Rollback
    end
  end
end
