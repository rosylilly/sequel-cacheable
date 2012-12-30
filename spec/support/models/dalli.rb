DalliCli = Dalli::Client.new('localhost:11211')

class DalliModel < Sequel::Model(:spec)
  plugin :cacheable, DalliCli
end
