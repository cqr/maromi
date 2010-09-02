class Maromi
  class Helper
    
    def initialize(request)
      @request = request
    end
    
    def request_for_authorization
      @request_for_authorization ||= Request.get!(@request.params['oauth_token'])
    end
    
    def consumer
      return @consumer unless @consumer.nil?
      if is_authorization_request?
        return @consumer = ConsumerRequestProxy.new(request_for_authorization)
      end
    end
    
    def is_authorization_request?
      @request.path == '/oauth/authorize'
    end
    
    def require_oauth_authentication!
      request, consumer, authorization = OAuth::RequestProxy.proxy(@request)
      verified = OAuth::Signature.verify(request) do |r|
        consumer = Consumer.get!(r.parameters['oauth_consumer_key'])
        p consumer
        authorization = Authorization.first(:consumer => consumer, :token => r.parameters['oauth_token'])
        p authorization
        [authorization.secret, consumer.shared_secret]
      end
      
      raise 'no good' unless verified
      
      @consumer = ConsumerAuthorizationProxy.new(authorization, consumer)
    end
    
    def consumer_name
      @consumer_name ||= (consumer.nickname || callback)
    end
    
    def callback
      @callback ||= (is_authorization_request? ? request_for_authorization.callback_url : consumer.callback_url)
    end
    
    def create_consumer(params = {})
      consumer = Consumer.create(:shared_secret => params[:secret] || Token.new, :consumer_key => params[:token] || Token.new(16), :callback_url => params[:callback])
      if consumer.valid?
        return ConsumerProxy.new consumer
      else
        @errors = consumer.errors
        return false
      end
    end
    
    def consumer_errors; @errors; end
  
  end
end