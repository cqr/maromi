class Maromi
  class Request
    include DataMapper::Resource
    
    property :token,        String, :key => true
    property :token_secret, String, :required => true
    property :user_id,      Integer
    property :scopes,       String
    property :verifier,     String
    property :verified,     Boolean
    property :callback_url, String, :required => true
    
    belongs_to :consumer
  end
end