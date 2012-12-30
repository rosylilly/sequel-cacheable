require 'msgpack'

module Sequel::Plugins
  module Cacheable
    class Packer
      def self.factory(lib)
        case lib
        when MessagePack
          MessagePackPacker.new
        else
          Packer.new
        end
      end

      def pack(obj)
        Marshal.dump(obj)
      end

      def unpack(string)
        Marshal.load(string)
      end
    end

    class MessagePackPacker < Packer
      def pack(obj)
        obj.to_msgpack
      end

      def unpack(string)
        MessagePack.unpack(string)
      end
    end
  end
end
