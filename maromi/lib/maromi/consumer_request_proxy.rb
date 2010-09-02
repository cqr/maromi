class Maromi
  class ConsumerRequestProxy
    
    def initialize(request)
      @request = request
    end
    
    def authorized!(params = {})
      @request.user_id = params[:by] if params[:by]
      @request.scopes = params[:to] if params[:to]
      @request.verified = true
      @request.verifier = (@request.callback_url == 'oob' ? rand(9999) : Token.new)
      @request.save!
      Maromi.authorized_request = @request
    end
    
    def name
      consumer.nickname
    end
    
    def callback
      @request.callback_url || consumer.callback_url
    end
    
    private
    
    def consumer
      @consumer ||= @request.consumer
    end
  end
end