class Maromi
  class ConsumerProxy
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
      @consumer.shared_secret
    end
    
    def token
      @consumer.consumer_key
    end
    
    def inspect
      "#<Maromi::ConsumerProxy callback:#{callback.inspect} name:#{name.inspect}>"
    end
  end
end