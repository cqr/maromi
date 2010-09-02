class Maromi
  class Authorization
    include DataMapper::Resource
    
    property :token, String, :key => true
    property :secret, String
    property :user_id, Integer
    property :scopes, String
    
    belongs_to :consumer
    
  end
end