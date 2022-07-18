$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "git_hub_integration"
require "dotenv"
require "timecop"
require "webmock/rspec"
Dotenv.load(".env.test")

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |conf|
  conf.include(WebmockHelpers)
  conf.include(EnvHelper)

  conf.before(:each) do
    Redis.new.flushdb
  end
end
