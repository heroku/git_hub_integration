require "spec_helper"

describe GitHubIntegration do
  before do
    ENV["RBNACL_SECRET"] = "n1v9ITbJ9KIkFa3fqs1XTlUkRToQNmp5Ekqy/aEMooM="
  end

  after do
    ENV.delete("RBNACL_SECRET")
  end

  it "has a version number" do
    expect(GitHubIntegration::VERSION).not_to be nil
  end

  module Rails
    class << self
      attr_reader :key, :value
    end

    def self.cache
      self
    end

    def self.write(key, value)
      @key = key
      @value = value
    end
  end

  it "stores the token encrypted" do
    GitHubIntegration.cache_encrypted_token("test")
    expect(Rails.value).to_not eql "test"
    decrypted_value = GitHubIntegration::TokenEncryption.decrypt_value(Rails.value)
    expect(decrypted_value).to eql("test")
  end
end
