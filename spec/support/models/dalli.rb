DalliCli = Dalli::Client.new('localhost:11211')

class DalliModel < Sequel::Model(:spec)
  plugin :cacheable, DalliCli, :query_cache => true
end
