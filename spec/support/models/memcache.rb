MemcacheCli = Memcache.new(:server => 'localhost:11211')

class MemcacheModel < Sequel::Model(:spec)
  plugin :cacheable, MemcacheCli, :query_cache => true
end
