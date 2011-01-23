class Maromi
  module Helpers
    # A little helper for storing authorizers on requests and authorizations
    # that knows how to deal with AR and DM objects
    module SmartAuthorizerMarshal
      
      # Sets Datamapper attributes properly in the case that obj is an AR or DM object
      # @param [Object] object the value to attach to the datamapper resource
      def authorizer=(obj)
        if defined? ActiveRecord and obj.is_a? ActiveRecord::Base
          attribute_set(:authorizer, Marshal.dump(obj.send(obj.class.primary_key)))
          attribute_set(:authorizer_class, obj.class)
          return obj
        elsif obj.class.included_modules.include? DataMapper::Resource
          attribute_set(:authorizer, Marshal.dump(obj.key[0]))
          attribute_set(:authorizer_class, obj.class)
        else
          attribute_set(:authorizer, Marshal.dump(obj))
        end
      end

      # Intelligently plucks objects stored using SAM.authorizer=(obj).
      # @return [Object] object previously stored in the datamapper resource
      def authorizer
        authorizer, klass = attribute_get(:authorizer), attribute_get(:authorizer_class)
        return nil if authorizer.nil?
        return authorizer if authorizer = Marshal.load(attribute_get(:authorizer)) and ( klass.nil? || klass == '' )
        if defined? ActiveRecord and (klass = eval(klass)).ancestors.include? ActiveRecord::Base
          return klass.find(authorizer)
        else
          return klass.get!(authorizer)
        end
      end
    end
  end
end