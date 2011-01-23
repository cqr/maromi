class Maromi
  module Helpers
    module Sinatra
      
      # @return [LazyObject] the {LazyObject} attached to this request
      def maromi
        env['maromi.helper']
      end
      
      # @return [String] the oauth_token attached to this request
      def oauth_token
        params[:oauth_token]
      end
      
      # @return [Proxies::Consumer, Proxies::ConsumerRequest, Proxies::ConsumerAuthorization] the consumer proxy which corresponds to the level of access attached to this request
      def consumer
        maromi.consumer
      end
      
      def require_oauth_authentication!
        maromi.require_oauth_authentication!
      end
      
      def temporary_consumer
        maromi.request_for_authorization
      end
      
      def new_consumer(*args)
        maromi.new_consumer(*args)
      end
      
    end
  end
end