class Maromi
  module Helpers
    # The Lazy Object is automatically attached to the Rack ENV as maromi.helper
    # This basically allows you to interact with Maromi. For the most part, the 
    # interface is built up in a particular framework's set of helpers, such as
    # in {Maromi::Helpers::Sinatra}, though direct use of the LazyObject is permitted.
    class LazyObject

      # @api private
      def initialize(request)
        @request = request
      end

      
      def request_for_authorization
        @request_for_authorization ||= Request.get!(@request.params['oauth_token'])
      rescue DataMapper::ObjectNotFoundError
        @request_for_authorization = nil
      end

      # 
      def consumer
        return @consumer unless @consumer.nil?
        if is_authorization_request? && request_for_authorization
          return @consumer = Proxies::ConsumerRequest.new(request_for_authorization)
        elsif oauth_authenticated?
          return @consumer
        end
        return @consumer
      end

      # @return [Boolean] whether or not the current request should use temporary credentials
      def is_authorization_request?
        @request.path == '/oauth/authorize'
      end

      # Fires up the whole thing. Makes sure that the current request is authenticated and
      # causes Rack to return a 401 Unauthorized immediately if it is not.
      def require_oauth_authentication!
        throw :unauthorized unless oauth_authenticated?
      end

      # @return [Boolean] whether or not the current request is authenticated by oauth.
      def oauth_authenticated?
        request, consumer, authorization = OAuth::RequestProxy.proxy(@request)
        if OAuth::Signature.verify(request) do |r|
            raise 'Bad Consumer Key' unless consumer = Consumer.get!(r.parameters['oauth_consumer_key'])
            raise 'Bad Token' unless authorization = Authorization.first(:consumer => consumer, :token => r.parameters['oauth_token']) || Request.first(:consumer => consumer, :token => r.parameters['oauth_token'])
            [authorization.secret, consumer.secret]
          end
          @consumer = Proxies::ConsumerAuthorization.new(authorization, consumer) if authorization.is_a? Authorization
          @consumer = Proxies::ConsumerRequest.new(authorization, consumer) if authorization.is_a? Request
          return true if authorization.is_a? Authorization
        end
      rescue Exception => e
        return false
      end

      # @return [Maromi::Consumer]a new consumer
      def new_consumer(params={})
        consumer = Consumer.new(:secret => params[:secret] || Helpers::Token.new, :token => params[:token] || Helpers::Token.new(16), :callback_url => params[:callback])
      end

    end
  end
end