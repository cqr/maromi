class Maromi
  class Request
    include DataMapper::Resource
    
    property :token,        String, :key => true
    property :secret,       String, :required => true
    property :authorizer,   Object
    property :authorizer_class, String
    property :scopes,       String
    property :verifier,     String
    property :verified,     Boolean
    property :callback_url, String, :required => true
    
    belongs_to :consumer
    
    include Helpers::SmartAuthorizerMarshal
    
    def upgrade!
      authorization = Authorization.create(:token => Helpers::Token.new(16),
                                           :secret => Helpers::Token.new,
                                           :authorizer => authorizer,
                                           :scopes => scopes, 
                                           :consumer => consumer)
      destroy!
      return authorization
    rescue Exception => e
      p e
      p e.message
      p e.backtrace
    end
  end
end