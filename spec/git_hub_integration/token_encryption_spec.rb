require "spec_helper"

RSpec.describe GitHubIntegration::TokenEncryption do
  it "raise an error when RBNACL_SECRET is missing" do
    original_secret = ENV["RBNACL_SECRET"]
    ENV["RBNACL_SECRET"] = nil

    expect do
      GitHubIntegration::TokenEncryption.encrypt_value("test")
    end.to raise_error(RbnaclSecretMissing)

    ENV["RBNACL_SECRET"] = original_secret
  end

  describe "When RBNACL_SECRET is present" do
    it "does not raise an error when RBNACL_SECRET is present" do
      expect do
        GitHubIntegration::TokenEncryption.encrypt_value("test")
      end.to_not raise_error(RbnaclSecretMissing)
    end

    it "encrypts/decrypt the value" do
      encrypted_value = GitHubIntegration::TokenEncryption.encrypt_value("test")
      expect(encrypted_value).to_not eql("test")
      decrypted_value = GitHubIntegration::TokenEncryption.decrypt_value(encrypted_value)
      expect(decrypted_value).to eql("test")
    end
  end
end
