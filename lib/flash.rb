require 'json'
require 'webrick'

class Flash
    def initialize(req)
      @now = false
      @values = {}
      req.cookies.each do |cookie|
        if cookie.name == "_rails_lite_flash"
          @now_values = JSON.parse(cookie.value)
        end
      end
    end

    def [](mark)
      raise if now?
      all_values = @values.merge(@now_values)
      all_values[mark.to_s] || all_values[mark.to_sym]
    end

    def []=(mark, value)
      now? ? @now_values[mark] = value : @values[mark] = value
      @now = false
    end

    def now
      @now = true
      self
    end

    def now?
      !!@now
    end

    def store_flash(res)
      raise if now?
      cookie = WEBrick::Cookie.new('_rails_lite_flash', @values.to_json)
      res.cookies << cookie
    end
  end
