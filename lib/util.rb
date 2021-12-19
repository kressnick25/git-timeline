require 'faraday'

# Common utility methods
module Util
  def http_get_json(url)
    headers = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'
    }

    response = Faraday.get(url, {}, headers)
    JSON.parse(response.body, symbolize_names: true)
  end
end
