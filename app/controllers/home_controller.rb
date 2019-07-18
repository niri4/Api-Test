class HomeController < ApplicationController

  get '/' do
    erb :index
  end

  post '/api_validate' do
    byebug
  end
end
