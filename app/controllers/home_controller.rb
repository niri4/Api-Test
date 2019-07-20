class HomeController < ApplicationController

  get '/' do
    erb :index, layout: :layout
  end

  post '/api_validate' do
    account_id = params['account_number']
    auth_token = params['auth_token']
    module_name = params['module_name']
    method_name = params['method_name']
    parameters =  params['attributes']
    test_case = params['test_case']
    api = ApiResult.new
    @result = api.get_result account_id, auth_token, module_name, method_name, parameters, test_case
    erb :api_validate, layout: :layout
  end
end
