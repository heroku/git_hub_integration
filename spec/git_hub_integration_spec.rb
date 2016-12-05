require "spec_helper"

describe GitHubIntegration do
  it "has a version number" do
    expect(GitHubIntegration::VERSION).not_to be nil
  end

  it "uses a cached token up until 2 minutes before it expires" do
    Timecop.freeze

    expiration_time = 1.hour.from_now.utc
    body = { token: "123", expires_at: expiration_time.iso8601 }.to_json
    request = stub_github_integration_request(body)

    GitHubIntegration.access_token

    token = GitHubIntegration.redis.get(GitHubIntegration::ACCESS_TOKEN_KEY)
    expires_at = GitHubIntegration.redis.get(GitHubIntegration::EXPIRATION_KEY)
    decrypted_token = GitHubIntegration::TokenEncryption.decrypt_value(token)
    expect(decrypted_token).to eql("123")
    expect(expires_at).to eql(1.hour.from_now.utc.to_s)

    Timecop.travel(1.minute)
    GitHubIntegration.access_token

    Timecop.travel(expiration_time - 2.minutes)
    GitHubIntegration.access_token

    expect(request).to have_been_requested.twice
  end

  it "expires and get a new token" do
    GitHubIntegration.redis.set(GitHubIntegration::ACCESS_TOKEN_KEY, "123")
    GitHubIntegration.redis.set(GitHubIntegration::EXPIRATION_KEY, Time.now.utc - 1)
    expect(GitHubIntegration).to be_expired

    request = stub_github_integration_request

    GitHubIntegration.client

    expect(request).to have_been_requested
  end

  it "stores the token encrypted" do
    GitHubIntegration.cache_encrypted_token("test")
    token = GitHubIntegration.redis.get(GitHubIntegration::ACCESS_TOKEN_KEY)
    expect(token).to_not eql "test"
    decrypted_value = GitHubIntegration::TokenEncryption.decrypt_value(token)
    expect(decrypted_value).to eql("test")
  end
end
