module Sequel::Plugins
  module Cacheable
    class DalliDriver < Driver
      def del(key)
        @store.delete(key)

        return nil
      end

      def expire(key, time)
        if time > 0
          @store.touch(key, time)
        else
          @store.delete(key)
        end
      end
    end
  end
end
