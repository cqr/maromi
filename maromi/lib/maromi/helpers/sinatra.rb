class Maromi
  module Helpers
    module Sinatra
      
      
      
      def maromi
        env['maromi.helper']
      end
      
      def consumer_errors
        maromi.consumer_errors
      end
      
      MAROMI_DELEGATED_METHODS = [:consumer_name, :create_consumer]
      
      MAROMI_DELEGATED_METHODS.each do |method_name|
        define_method method_name, Proc.new {|args| maromi.send method_name, args }
      end
      
    end
  end
end