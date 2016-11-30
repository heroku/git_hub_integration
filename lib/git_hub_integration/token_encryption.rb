class RbnaclSecretMissing < StandardError; end

module GitHubIntegration
  module TokenEncryption
    def self.rbnacl_secret
      ENV["RBNACL_SECRET"] ||
        raise(RbnaclSecretMissing, "No RBNACL_SECRET environmental variable set")
    end

    def self.rbnacl_secret_bytes
      rbnacl_secret.unpack("m0").first
    end

    def self.rbnacl_simple_box
      @rbnacl_simple_box ||=
        RbNaCl::SimpleBox.from_secret_key(rbnacl_secret_bytes)
    end

    def self.decrypt_value(value)
      rbnacl_simple_box.decrypt(Base64.decode64(value))
    end

    def self.encrypt_value(value)
      return if value.nil? || value == ""
      Base64.encode64(rbnacl_simple_box.encrypt(value)).chomp
    end
  end
end
