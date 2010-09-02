class Maromi
  module Token
    def self.new(size=32)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/,'')
    end
  end
end