class Maromi
  # A wrapper for the DataMapper models used by Maromi
  module Models
    
    # proxy to Maromi::Consumer
    def Consumer
      ::Maromi::Consumer
    end
    
    # proxy to Maromi::Authorization
    def Authorization
      ::Maromi::Authorization
    end
    
    #proxy to Maromi::Request
    def Request
      ::Maromi::Request
    end
  end
end

require 'maromi/models/consumer'
require 'maromi/models/authorization'
require 'maromi/models/request'