require 'faraday'
require 'json'
require 'date'

require_relative 'provider'

# Github git provider
class Github < Provider
  def user_name
    @client.user.name
  end

  def calendar(user)
    json = get_raw_data(user)

    # flatten results
    result = {}
    weeks = json['data']['user']['contributionsCollection']['contributionCalendar']
    weeks.each do |_key, week|
      week.each do |days|
        days['contributionDays'].each do |day|
          result[day['date']] = day['contributionCount']
        end
      end
    end

    result
  end

  def self.name
    'Github'
  end

  private

  def get_raw_data(user)
    url = 'https://api.github.com/graphql'
    token = @credentials['personal-access-token']
    now = DateTime.now()

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}",
      'X-REQUEST-TYPE' => 'GraphQL'
    }

    query = "query {
      user(login: \"#{user}\") {
          email
          createdAt
          contributionsCollection(from: \"#{now.prev_year.iso8601}\", to: \"#{now.iso8601}\") {
              contributionCalendar {
                  weeks {
                      contributionDays {
                          date
                          contributionCount
                      }
                  }
              }
          }
      }
    }"

    response = Faraday.post(url, { 'query' => query }.to_json, headers)
    JSON.parse(response.body)
  end
end
