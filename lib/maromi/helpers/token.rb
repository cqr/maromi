class Maromi
  module Helpers
    # There was going to be more to this at one point, but all it does is to
    # generate a random string suitable for use as a token or secret.
    module Token
      
      # Generates a pseudorandom string suitable for use as a token or secret.
      # @return [String] a pseudorandom string
      # @param [Integer] size the maximum length of the string
      def self.new(size=32)
        Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/,'')
      end
    end
  end
end