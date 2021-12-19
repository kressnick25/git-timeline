# A git provider
class Provider
  def initialize(credentials = nil)
    @credentials = credentials
  end

  def init
    # Authorize and create connection
  end

  def calendar(_user)
    # get calendar for a user since date provided
    raise NotImplementedError
  end
end
