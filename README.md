# GitHubIntegration

Use GitHub Integration with Octokit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'git_hub_integration', github: 'heroku/git_hub_integration'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_hub_integration

## Installation

### Dependencies
- `RbNACL`
- `Redis`
- `Octokit`

### ENV Variables
`RBNACL_SECRET`
You will need a `RBNACL_SECRET` environment variable to encrypt cached tokens.
You can generate one using the following code

```
dd if=/dev/urandom bs=32 count=1 2>/dev/null | openssl base64
```
`GITHUB_API_TOKEN` - Legacy API token

`GITHUB_INTEGRATION_ID` - The id of your GitHub App. After creating the GitHub app, you can view this id in the GitHub UI by visiting the [GitHub Apps page](https://github.com/organizations/heroku/settings/apps) and clicking `Edit` next to your GitHub App. The ID will be in the `About` section.
`GITHUB_PRIVATE_KEY` - This private key is generated and can be downloaded locally when you first create your GitHub app.

`GITHUB_INTEGRATION_APPLICATION_ID` - Setting this will mean that the gem will start using the GitHub app instead of the legacy GitHub token, only set this when you're ready to start using the integration. The integration application ID is unique to each installation of the GitHub app. It is generated when you install the GitHub App on the Heroku account. After installing the app, visit the [Installed GitHub Apps page](https://github.com/organizations/heroku/settings/installations) and click on `Configure` next to your GitHub App. The integration application ID will be visible in the URL.

## Usage

The method `GitHubIntegration.client` returns an Octokit Client. If the environment variable `GITHUB_INTEGRATION_APPLICATION_ID` is set it will return a client for your GitHub App Integration bot. If it is not set, it will return a client from the Legacy API token.

Use of `GitHubIntegration.legacy_client` will allow you to use a Legacy API client regardless of whether or not you have a `GITHUB_INTEGRATION_APPLICATION_ID` in your environment variables.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

### Releasing

1. Update the version number in lib/git_hub_integration/version.rb
1. Build and Publish the gem
    1. Run `gem_push=no bundle exec rake release`
    1. Run `package_cloud push heroku/gemgate pkg/git_hub_integration-x.x.x.gem`

Note: IF you don't have packagecloud setup refer to the [documentation](https://packagecloud.io/docs#cli_install)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/git_hub_integration. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

