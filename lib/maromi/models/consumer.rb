class Maromi
  class Consumer
    include DataMapper::Resource
    
    property :token,          String, :key => true
    
    property :secret,         String
    property :name,           String
    property :callback_url,   String,
          :format => %r{https?://([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?},
              :required => true,
              :unique => true,
              :messages => {
                :is_unique => 'The callback url is already in use',
                :format => 'The callback url does not appear to be valid'
              }
    
    
    has n, :requests
    has n, :authorizations
    
    def callback_url=(callback)
      attribute_set(:callback_url, callback.downcase)
    end
  end
end