class Maromi
  class Authorization
    include DataMapper::Resource
    
    property :token, String, :key => true
    property :secret, String
    property :authorizer, Object
    property :authorizer_class, String
    property :scopes, String
    
    belongs_to :consumer
    
    include Helpers::SmartAuthorizerMarshal
  end
end