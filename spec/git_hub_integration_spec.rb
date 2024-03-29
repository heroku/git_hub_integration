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

    token = GitHubIntegration.redis.get(GitHubIntegration.access_token_key)
    expires_at = GitHubIntegration.redis.get(GitHubIntegration.expiration_key)
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
    GitHubIntegration.redis.set(GitHubIntegration.access_token_key, "123")
    GitHubIntegration.redis.set(GitHubIntegration.expiration_key, Time.now.utc - 1)
    expect(GitHubIntegration).to be_expired

    request = stub_github_integration_request

    GitHubIntegration.client

    expect(request).to have_been_requested
  end

  it "stores the token encrypted" do
    GitHubIntegration.cache_encrypted_token("test")
    token = GitHubIntegration.redis.get(GitHubIntegration.access_token_key)
    expect(token).to_not eql "test"
    decrypted_value = GitHubIntegration::TokenEncryption.decrypt_value(token)
    expect(decrypted_value).to eql("test")
  end

  it "returns nil if Redis returns an empty string or the key does not exist" do
    expect(GitHubIntegration).to receive(:redis).and_return(double(get: ""))
    expect(GitHubIntegration.expires_at).to be_nil

    expect(GitHubIntegration).to receive(:redis).and_return(double(get: nil))
    expect(GitHubIntegration.expires_at).to be_nil
  end

  describe "fetching GitHub App tokens" do
    describe ".github_integration_id" do
      it "should fetch from the environment variable GITHUB_INTEGRATION_ID and cast it as an integer if set" do
        with_environment("GITHUB_INTEGRATION_ID" => "789") do
          expect(GitHubIntegration.github_integration_id).to eq(789)
        end
      end

      it "should return nil if GITHUB_INTEGRATION_ID is not set and a thread-var is not set" do
        with_environment("GITHUB_INTEGRATION_ID" => nil) do
          expect(GitHubIntegration.github_integration_id).to be_nil
        end
      end

      it "should return the value of the thread-var if set" do
        with_environment("GITHUB_INTEGRATION_ID" => nil) do
          Thread.current[:github_integration_id] = 789
          expect(GitHubIntegration.github_integration_id).to eq(789)
        end
      end
    end

    describe ".github_private_key" do
      it "should fetch from the environment variable GITHUB_PRIVATE_KEY if set" do
        # Requires a valid RSA private key
        expect(ENV["GITHUB_PRIVATE_KEY"]).to_not be_nil
        expect(GitHubIntegration.github_private_key.to_s).to eq(ENV["GITHUB_PRIVATE_KEY"])
      end

      it "should return nil if GITHUB_PRIVATE_KEY is not set and a thread-var is not set" do
        with_environment("GITHUB_PRIVATE_KEY" => nil) do
          expect(GitHubIntegration.github_private_key).to be_nil
        end
      end

      it "should return the value of the thread-var if set" do
        # Requires a valid RSA private key
        private_key = ENV["GITHUB_PRIVATE_KEY"]
        with_environment("GITHUB_PRIVATE_KEY" => nil) do
          Thread.current[:github_private_key] = private_key
          expect(GitHubIntegration.github_private_key.to_s).to eq(private_key)
        end
      end
    end

    describe ".github_installation_id" do
      it "should fetch from the environment variable GITHUB_INTEGRATION_APPLICATION_ID if set" do
        with_environment("GITHUB_INTEGRATION_APPLICATION_ID" => "789") do
          expect(GitHubIntegration.github_installation_id).to eq("789")
        end
      end

      it "should return nil if GITHUB_INTEGRATION_APPLICATION_ID is not set and a thread-var is not set" do
        with_environment("GITHUB_INTEGRATION_APPLICATION_ID" => nil) do
          expect(GitHubIntegration.github_installation_id).to be_nil
        end
      end

      it "should return the value of the thread-var if set" do
        with_environment("GITHUB_INTEGRATION_APPLICATION_ID" => nil) do
          Thread.current[:github_installation_id] = "789"
          expect(GitHubIntegration.github_installation_id).to eq("789")
        end
      end
    end
  end

  describe "redis" do
    before do
      described_class.instance_variable_set(:@redis, nil)
    end

    context "when REDIS_OPENSSL_VERIFY_MODE is set to 'none'" do
      it "creates a new Redis instance with ssl_params set to VERIFY_NONE" do
        with_environment("REDIS_OPENSSL_VERIFY_MODE" => "none") do
          redis = described_class.redis # Should use the environment variable during instantiation.
          expect(redis.instance_variable_get(:@options)[:ssl_params][:verify_mode]).to eq(OpenSSL::SSL::VERIFY_NONE)
        end
      end
    end

    context "when REDIS_OPENSSL_VERIFY_MODE is not set" do
      it "creates a new Redis instance with default ssl_params" do
        with_environment("REDIS_OPENSSL_VERIFY_MODE" => nil) do
          redis = described_class.redis # Should use the environment variable during instantiation.
          expect(redis.instance_variable_get(:@options)[:ssl_params][:verify_mode]).to eq(OpenSSL::SSL::VERIFY_PEER)
        end
      end
    end
  end
end
