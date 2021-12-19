require 'sinatra'
require 'sinatra/cors'
require 'sinatra/reloader' if development?
require 'require_all'
require 'json'
require 'logger'

require_all 'lib'
# Setup CORS
set :allow_origin, 'http://example.com http://foo.com'
set :allow_methods, 'GET,HEAD,POST'
set :allow_headers, 'content-type,if-modified-since'
set :expose_headers, 'location,link'

$CONFIG = ConfigLoader.new('credentials.yml')

$PROVIDERS = {
  'github' => Github.new($CONFIG.config_for('github')),
  'gitlab' => Gitlab.new
}

def default_response(body)
  headers = {
    'Content-Type' => 'application/json'
  }

  json = JSON.generate(body)

  [200, headers, json]
end

get '/calendar' do
  calendar = {}
  $PROVIDERS.each do |name, provider|
    user = params[name]
    next unless user

    provider.init
    provider_calendar = provider.calendar(user)
    provider_calendar.each do |date, count|
      if calendar[date]
        calendar[date] += count
      else
        calendar[date] = count
      end
    end
  end

  default_response(calendar)
end

get '/providers' do
  provider_names = []
  $PROVIDERS.each do |name, _provider|
    provider_names.append(name)
  end

  default_response(provider_names)
end
