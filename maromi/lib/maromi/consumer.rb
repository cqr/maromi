class Maromi
  class Consumer
    include DataMapper::Resource
    
    property :nickname,      String
    property :callback_url,  String, :format => %r{http(s?)://[a-z0-9\-]{2,}(\.[a-z]{2,})+(\:[0-9]+)?(/.*)*}, :required => true, :unique => true, :messages => {
      :is_unique => 'is already in use',
      :format => 'does not appear to be a valid url'
    }
    property :shared_secret, String
    property :consumer_key,  String, :key => true
    
    has n, :requests
    
    has n, :authorizations
    
    def callback_url=(callback)
      attribute_set(:callback_url, callback.downcase)
    end
  end
end