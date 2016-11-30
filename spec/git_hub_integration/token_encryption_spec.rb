require "spec_helper"

RSpec.describe GitHubIntegration::TokenEncryption do
  it "raise an error when RBNACL_SECRET is missing" do
    expect do
      GitHubIntegration::TokenEncryption.encrypt_value("test")
    end.to raise_error(RbnaclSecretMissing)
  end

  describe "When RBNACL_SECRET is present" do
    before do
      ENV["RBNACL_SECRET"] = "n1v9ITbJ9KIkFa3fqs1XTlUkRToQNmp5Ekqy/aEMooM="
    end

    after do
      ENV.delete("RBNACL_SECRET")
    end

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
