require 'json'
require 'webrick'

class Session
  def initialize(req)
    @values = {}
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        value_hash = JSON.parse(cookie.value)
        key = value_hash.keys.first
        self[key] = value_hash[key]
      end
    end
  end

  def [](key)
    @values[key]
  end

  def []=(key, val)
    @values[key] = val
  end

  def store_session(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app', @values.to_json)
    res.cookies << cookie
  end
end
