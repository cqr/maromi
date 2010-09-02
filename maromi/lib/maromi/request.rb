class Maromi
  class Request
    include DataMapper::Resource
    
    property :token,        String, :key => true
    property :token_secret, String
    property :verifier,     String
    property :verified,     Boolean
    property :callback_url, String
    
    belongs_to :consumer
  end
end