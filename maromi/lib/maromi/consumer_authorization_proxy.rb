class Maromi
  class ConsumerAuthorizationProxy
    
    def initialize(access, consumer = nil)
      @access = access
      @consumer = consumer || @access.consumer
    end
    
    def user_id
      @access.user_id
    end
  end
end