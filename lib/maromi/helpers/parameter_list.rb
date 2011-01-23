class Maromi
  module Helpers
    class ParameterList
      def initialize(hash={})
        @parameters = hash
      end
      
      def []=(key, value)
        @parameters[key] = value
      end
      
      def [](key)
        @parameters[key]
      end
      
      def urlencoded
        @parameters.map{|key,value| "#{key}=#{value}"}.join('&')
      end
      
      def method_missing(symbol, arguments)
        method = symbol.to_s
        if method[-1] == '='
          self[method[0..(method.length-1)].intern] = arguments[0]
        else
          self[symbol]
        end
      end
    end
  end
end