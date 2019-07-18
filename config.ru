require 'sinatra/base'
require_relative './config/environment'

# # pull in the helpers and controllers
Dir.glob('./app/{helpers,controllers}/*.rb').each { |file| require file }

# map the controllers to routes
map('/') { run HomeController }
