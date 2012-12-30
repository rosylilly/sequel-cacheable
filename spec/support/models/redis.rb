RedisCli = Redis.new(:server => 'localhost:6379')

class RedisModel < Sequel::Model(:spec)
  plugin :cacheable, RedisCli, :query_cache => true
end
