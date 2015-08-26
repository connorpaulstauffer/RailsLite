require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require_relative '../lib/controller'
require_relative '../lib/router'
require_relative '../lib/active_record/attr_accessor_object'
require_relative '../lib/active_record/sql_object'
require_relative '../lib/active_record/searchable'
require_relative '../lib/active_record/associatable'
require_relative '../lib/active_record/db_connection'
require 'byebug'


# class Cat
#   attr_reader :name, :owner
#
#   def self.all
#     @cat ||= []
#   end
#
#   def initialize(params = {})
#     params ||= {}
#     @name, @owner = params["name"], params["owner"]
#   end
#
#   def save
#     return false unless @name.present? && @owner.present?
#
#     Cat.all << self
#     true
#   end
#
#   def inspect
#     { name: name, owner: owner }.inspect
#   end
# end

class Cat < SQLObject
  belongs_to :owner, class_name: :Human
end

class Human < SQLObject
  has_many :cats
end

class CatsController < Controller
  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      flash[:notice] = "Cat successfully created"
      redirect_to("/cats")
    else
      flash.now[:error] = "Invalid input"
      render :new
    end
  end

  def index
    @cats = Cat.all
    render :index
  end

  # def show
  #   a = params["id"]
  #   a = a.to_i
  #   @cat = Cat.find(a)
  #   byebug
  #   # @cat = Cat.find(params[:id])
  #   render :show
  # end

  def new
    @cat = Cat.new
    render :new
  end
end

DBConnection.reset

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
