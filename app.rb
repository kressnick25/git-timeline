require 'sinatra'
require 'sinatra/cors'
require 'sinatra/reloader' if development?
require 'require_all'
require 'json'
require 'logger'

require_all 'lib'
# Setup CORS
set(:allow_origin, 'http://example.com http://foo.com')
set(:allow_methods, 'GET,HEAD,POST')
set(:allow_headers, 'content-type,if-modified-since')
set(:expose_headers, 'location,link')

$CONFIG = ConfigLoader.new('credentials.yml')

$CACHE = Cache.new

$PROVIDERS = {
  'github' => Github.new($CONFIG.config_for('github')),
  'gitlab' => Gitlab.new
}

get '/calendar' do
  calendar = {}
  $PROVIDERS.each do |name, provider|
    user = params[name]
    next unless user

    provider.init
    provider_cal = $CACHE.fetch("#{name}-#{user}") do
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
  $PROVIDERS.each do |name, _provider|
    provider_names.append(name)
  end

  body(provider_names)
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
