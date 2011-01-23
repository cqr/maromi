class Maromi
  # A collection of utilities in use in Maromi
  module Helpers
    autoload :Sinatra, 'maromi/helpers/sinatra'
    autoload :LazyObject, 'maromi/helpers/lazy_object'
    autoload :Token, 'maromi/helpers/token'
    autoload :ParameterList, 'maromi/helpers/parameter_list'
    autoload :SmartAuthorizerMarshal, 'maromi/helpers/smart_authorizer_marshal'
  end
end