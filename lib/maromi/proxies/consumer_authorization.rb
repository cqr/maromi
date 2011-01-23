class Maromi
  module Proxies
    class ConsumerAuthorization
      
      def initialize(access, consumer = nil)
        @access, @consumer = access, consumer
      end
      
      def authorizer
        @authorizer ||= access.authorizer
      end
      alias_method :user, :authorizer
      
      private
      
      attr_reader :access
      
      def consumer
        @consumer ||= access.consumer
      end
      
    end
  end
end