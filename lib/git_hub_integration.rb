unless defined?(ActiveSupport::Duration)
  require "git_hub_integration/core_ext/numeric"
end
require "base64"
require "git_hub_integration/token_encryption"
require "git_hub_integration/version"
require "json"
require "jwt"
require "octokit"
require "rbnacl"
require "redis"

# Github authentication
module GitHubIntegration
  MACHINE_MAN = "application/vnd.github.machine-man-preview+json".freeze
  EXPIRATION = 30

  def self.legacy_client(access_token = nil, api_endpoint = nil)
    access_token ||= ENV["GITHUB_API_TOKEN"]
    Octokit::Client.new(access_token: access_token,
                        api_endpoint: api_endpoint)
  end

  def self.client
    if github_installation_id
      Octokit::Client.new(access_token: access_token,
                          default_media_type: MACHINE_MAN)
    else
      legacy_client
    end
  end

  def self.access_token
    if expired?
      set_fresh_github_access_token
    end
    decrypted_access_token
  end

  def self.expires_at
    expires_at = redis.get(expiration_key)
    return unless expires_at && !expires_at.empty?
    Time.parse(expires_at)
  end

  def self.expired?
    !expires_at || 2.minutes.from_now.utc >= expires_at
  end

  def self.set_fresh_github_access_token
    response = Octokit.client.post(
      "/app/installations/#{github_installation_id}/access_tokens",
      headers: {
        "Authorization" => "Bearer #{github_access_token_jwt}",
        "Accept" => "application/vnd.github.machine-man-preview+json"
      }
    )
    cache_encrypted_token(response[:token])
    redis.set(expiration_key, response[:expires_at])
  end

  def self.github_access_token_jwt
    payload = {
      iss: github_integration_id,
      iat: Time.now.utc.to_i,
      exp: 5.minutes.from_now.utc.to_i
    }
    JWT.encode payload, github_private_key, "RS256"
  end

  def self.github_integration_id
    ENV["GITHUB_INTEGRATION_ID"]&.to_i || Thread.current[:github_integration_id]
  end

  def self.github_private_key
    key = ENV["GITHUB_PRIVATE_KEY"] || Thread.current[:github_private_key]
    OpenSSL::PKey::RSA.new(key) if key
  end

  def self.github_installation_id
    ENV["GITHUB_INTEGRATION_APPLICATION_ID"] || Thread.current[:github_installation_id]
  end

  def self.cache_encrypted_token(token)
    encrypted_token = TokenEncryption.encrypt_value(token)
    redis.set(access_token_key, encrypted_token)
  end

  def self.decrypted_access_token
    TokenEncryption.decrypt_value(redis.get(access_token_key))
  end

  def self.redis
    @redis ||= Redis.new(
      url: ENV["REDIS_URL"],
      ssl_params: { verify_mode: ENV["REDIS_OPENSSL_VERIFY_MODE"] == "none" ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER }
    )
  end

  def self.access_token_key
    ["github", github_integration_id, github_installation_id, "access_token"].join(".")
  end

  def self.expiration_key
    ["github", github_integration_id, github_installation_id, "expiration"].join(".")
  end
end
