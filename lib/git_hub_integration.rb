require "git_hub_integration/core_ext/numeric"
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
  ACCESS_TOKEN_KEY = "github.access_token".freeze
  EXPIRATION_KEY = "github.expiration".freeze
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
    expires_at = redis.get(EXPIRATION_KEY)
    return unless expires_at
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
    redis.set(EXPIRATION_KEY, response[:expires_at])
  end

  def self.github_access_token_jwt
    payload = {
      iss: ENV["GITHUB_INTEGRATION_ID"].to_i,
      iat: Time.now.utc.to_i,
      exp: 5.minutes.from_now.utc.to_i
    }
    JWT.encode payload, github_private_key, "RS256"
  end

  def self.github_private_key
    OpenSSL::PKey::RSA.new(ENV["GITHUB_PRIVATE_KEY"])
  end

  def self.github_installation_id
    ENV["GITHUB_INTEGRATION_APPLICATION_ID"]
  end

  def self.cache_encrypted_token(token)
    encrypted_token = TokenEncryption.encrypt_value(token)
    redis.set(ACCESS_TOKEN_KEY, encrypted_token)
  end

  def self.decrypted_access_token
    TokenEncryption.decrypt_value(redis.get(ACCESS_TOKEN_KEY))
  end

  def self.redis
    @redis ||= Redis.new(url: ENV["REDIS_URL"])
  end
end
