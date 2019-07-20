class ApiResult

  def get_result account_id, auth_token, module_name, method_name, parameters, test_case
    module_obj = get_module_object account_id, auth_token, module_name
    parameters_format =  set_parameter parameters
    result = result(module_obj, method_name, parameters_format)
    add_to_csv test_case, module_obj, method_name, parameters_format, result, module_name
    result
  end

  def result module_obj, method_name, parameters_format
    begin
      if parameters_format
        reslt = module_obj.send(method_name, parameters_format)
      else
        reslt = module_obj.send(method_name)
      end
    rescue URI::InvalidURIError
      reslt = invalid_url_resolver module_obj, method_name, parameters_format
    rescue => e
      reslt = "Gem return not handled error: =============#{e}"
    end
  end

  def invalid_url_resolver module_obj, method_name, parameters_format
    begin
      reslt = module_obj.send(method_name, parameters_format.values.first)
    rescue => e
     reslt = "Gem return not handled error: =============#{e}"
    end
  end

  def set_parameter parameters
    if parameters
      final_parameter = {}
      parameters['attribute_name'].each_with_index do |attr_name, index|
        set_value = value_converter parameters['data_type'][index], parameters['value'][index]
        final_parameter[attr_name.to_sym] = set_value
      end
      final_parameter
    else
      nil
    end
  end

  def value_converter data_type, value
    case data_type
    when 'integer'
      value.to_i
    when 'string'
      value.to_s
    when 'array'
      value[0] =''
      value[-1] = ''
      unless value.empty?
        value.split(',')
      else
        []
      end
    when 'hash'
      hsh = Hash.new
      value[0] =''
      value[-1] = ''
      unless value.empty?
        values = value.split(',')
        values.each do |val|
          a = val.split(':')
          last_val = a.last.strip
          last_val[0] = ''
          last_val[-1] =''
          hsh[a.first.strip.to_sym] =last_val
        end
        hsh
      else
        {}
      end
    end
  end

  def get_module_object account_id, auth_token, module_name
    case module_name
    when 'Campaigns'
      MaropostApi::Campaigns.new(account_id, auth_token)
    when 'AbTestCampaigns'
      MaropostApi::AbTestCampaigns.new(account_id, auth_token)
    when 'TransactionalCampaigns'
      MaropostApi::AbTestCampaigns.new(account_id, auth_token)
    when 'Contacts'
      MaropostApi::Contacts.new(account_id, auth_token)
    when 'Journeys'
      MaropostApi::Journeys.new(account_id, auth_token)
    when 'ProductsAndRevenue'
      MaropostApi::ProductsAndRevenue.new(account_id, auth_token)
    when 'RelationalTableRows'
      MaropostApi::RelationalTableRows.new(account_id, auth_token)
    when 'Reports'
      MaropostApi::Reports.new(account_id, auth_token)
    else
      "Error: Valid Module Name has an invalid value (#{moduel_name})"
    end
  end

  def add_to_csv test_case, module_obj, method_name, parameters_format, result, module_name
     CSV.open(File.join(File.dirname(__FILE__), '../public/test.csv'), "a+") do |csv|
       if result.class.to_s == 'String'
         csv << [test_case, module_name, method_name,'Not Handle', nil, result, '' ]
       else
         csv << [test_case, module_name, method_name,'working', result.success, result.errors, '' ]
       end
     end
  end
end
