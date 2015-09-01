require_relative './session'
require_relative './params'
require_relative './flash'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

class Controller
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req, @res, @params = req, res, Params::new(req, route_params)
  end

  def invoke_action(name)
    check_authenticity(name)
    send(name)
  end

  def check_authenticity(name)
    if [:create, :update, :destroy].include?(name)
      unless params[:authenticity_token] == form_authenticity_token
        raise "Invalid authenticity token"
      end
    end
  end

  def already_built_response?
    !!@already_built_response
  end

  def redirect_to(url)
    raise if already_built_response?
    res.header["location"] = url
    res.status = 302
    @already_built_response = true
    session.store_session(res)
    save_authenticity_token
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    raise if already_built_response?
    res.content_type, res.body = content_type, content
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render(template_name)
    raise if already_built_response?
    contents = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(contents).result(binding)
    render_content(template, "text/html")
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def form_authenticity_token
    @form_authenticity_token ||= find_authenticity_token
  end

  def find_authenticity_token
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_auth"
        return @form_authenticity_token = cookie.value
      end
    end
    save_authenticity_token
  end

  def save_authenticity_token
    @form_authenticity_token = generate_auth_token
    cookie = WEBrick::Cookie.new(
      '_rails_lite_auth',
      @form_authenticity_token.to_json
    )
    res.cookies << cookie
    @form_authenticity_token
  end

  def generate_auth_token
    SecureRandom.urlsafe_base64
  end
end
