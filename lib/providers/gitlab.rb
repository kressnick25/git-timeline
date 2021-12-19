# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative '../util'

# Gitlab git provider
class Gitlab < Provider
  include Util

  def calendar(user)
    http_get_json("https://gitlab.com/users/#{user}/calendar.json")
  end
end
