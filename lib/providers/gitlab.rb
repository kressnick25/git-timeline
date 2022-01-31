# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative '../util'

# Gitlab git provider
class Gitlab < Provider
  include Util

  # from https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/lib/gitlab/path_regex.rb
  PATH_START_CHAR = '[a-zA-Z0-9_\.]'
  PATH_REGEX_STR = PATH_START_CHAR + '[a-zA-Z0-9_\-\.]*'
  NAMESPACE_FORMAT_REGEX_JS = PATH_REGEX_STR + '[a-zA-Z0-9_\-]|[a-zA-Z0-9_]'
  REGEX = Regexp.new NAMESPACE_FORMAT_REGEX_JS

  def calendar(user)
    http_get_json("https://gitlab.com/users/#{user}/calendar.json")
  end

  def valid_username(username)
    username =~ REGEX
  end
end
