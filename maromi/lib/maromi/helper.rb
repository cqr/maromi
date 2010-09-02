class Maromi
  class Helper
    
    def initialize(request)
      @request = request
    end
    
    def name
      "My name is Maromi"
    end
    
    def request_for_authorization
      @request_for_authorization ||= Request.get!(@request.params['oauth_token'])
    end
    
    def consumer
      return @consumer unless @consumer.nil?
      if is_authorization_request?
        return @consumer = request_for_authorization.consumer
      else
        return @consumer = authorization.consumer
      end
    end
    
    def is_authorization_request?
      @request.path == '/oauth/authorize'
    end
    
    def consumer_name
      @consumer_name ||= (consumer.nickname || (is_authorization_request? ? request_for_authorization.callback_url : consumer.callback_url))
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