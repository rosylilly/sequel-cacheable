module Sequel::Plugins
  module Cacheable
    class MemcacheDriver < Driver
      def del(key)
        @store.delete(key)

        return nil
      end

      def expire(key, time)
        @store.set(key, @store.get(key), time)
      end
    end
  end
end
