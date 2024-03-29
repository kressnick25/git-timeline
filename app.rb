require 'sinatra'
require 'sinatra/cors'
require 'sinatra/reloader' if development?
require 'require_all'
require 'json'
require 'logger'

require_all 'lib'
# Setup CORS
set(:allow_origin, '*')
set(:allow_methods, 'GET,HEAD,POST')
set(:allow_headers, 'content-type,if-modified-since')
set(:expose_headers, 'location,link')

configure do
  token_github = ENV["TOKEN_GITHUB"]
  if token_github.nil? || token_github.empty?
    set :config, ConfigLoader.new('credentials.yml')
    token_github = settings.config.config_for('github')
    raise "No token for provider 'Github'" unless !token_github.nil? && !token_github.empty?
  end

  set :cache, Cache.new
  set :providers, {
    'github' => Github.new(token_github),
    'gitlab' => Gitlab.new
  }
end

get '/calendar' do
  calendar = {}
  settings.providers.each do |name, provider|
    user = params[name]
    next unless user

    valid_user = provider.valid_username(user)
    next unless valid_user

    provider.init
    provider_cal = settings.cache.fetch("#{name}-#{user}") do
      provider.calendar(user)
    end
    provider_cal.each do |date, count|
      if calendar[date]
        calendar[date] += count
      else
        calendar[date] = count
      end
    end
  end

  body(calendar)
end

get '/providers' do
  provider_names = []
  settings.providers.each do |name, _provider|
    provider_names.append(name)
  end

  body({"providers" => provider_names})
end

not_found do
  status(404)

  body({})
end

after do
  status(status || 200)

  headers \
    'Content-Type' => 'application/json'

  response = {
    'data' => body,
    'error' => status >= 400 ? status : nil
  }

  body(JSON.generate(response))
end
