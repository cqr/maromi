class Maromi
  module Proxies
    class Consumer
      def initialize(consumer)
        @consumer = consumer
      end
      
      def callback
        @consumer.callback_url
      end
      
      def name
        @consumer.nickname
      end
      
      def secret
        @consumer.secret
      end
      
      def token
        @consumer.token
      end
    end
  end
end