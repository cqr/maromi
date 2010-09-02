class Maromi
  module Helpers
    module Sinatra
      
      def maromi
        env['maromi.helper']
      end
      
      def consumer_errors
        maromi.consumer_errors
      end
      
      def oauth_token
        params[:oauth_token]
      end
      
      def consumer_name
        maromi.consumer_name
      end
      
      def consumer
        maromi.consumer
      end
      
      def require_oauth_authentication!
        maromi.require_oauth_authentication!
      end
      
      MAROMI_DELEGATED_METHODS = [:create_consumer]
      
      MAROMI_DELEGATED_METHODS.each do |method_name|
        define_method method_name, Proc.new {|args| maromi.send method_name, args }
      end
      
    end
  end
end