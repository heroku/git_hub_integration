require "git_hub_integration/version"
require "octokit"

# Github authentication
module GitHubIntegration
  ACCESS_TOKEN_KEY = "github.access_token".freeze
  EXPIRATION_KEY = "github.expiration".freeze
  MACHINE_MAN = "application/vnd.github.machine-man-preview+json".freeze
  EXPIRATION = 30

  def self.legacy_client
    Octokit::Client.new(access_token: ENV["GITHUB_API_TOKEN"])
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
    Rails.cache.read(ACCESS_TOKEN_KEY)
  end

  def self.expired?
    expires_at = Rails.cache.read(EXPIRATION_KEY)
    !expires_at || Time.now.utc >= expires_at
  end

  def self.set_fresh_github_access_token
    response = Octokit.client.post(
      "/installations/#{github_installation_id}/access_tokens",
      headers: {
        "Authorization" => "Bearer #{github_access_token_jwt}",
        "Accept" => "application/vnd.github.machine-man-preview+json"
      }
    )
    Rails.cache.write(ACCESS_TOKEN_KEY, response[:token])
    Rails.cache.write(EXPIRATION_KEY, response[:expires_at])
  end

  def self.github_access_token_jwt
    payload = {
      iss: ENV["GITHUB_INTEGRATION_ID"].to_i,
      iat: Time.now.to_i,
      exp: 1.minute.from_now.to_i
    }
    JWT.encode payload, github_private_key, "RS256"
  end

  def self.github_private_key
    OpenSSL::PKey::RSA.new(ENV["GITHUB_PRIVATE_KEY"])
  end

  def self.github_installation_id
    ENV["GITHUB_INTEGRATION_APPLICATION_ID"]
  end
end
