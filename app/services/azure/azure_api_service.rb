# frozen_string_literal: true

module Azure
  class AzureApiService
    attr_reader :connection_parameters

    def initialize(azure_account)
      base_uri = "#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/_apis"
      @connection_parameters = { username: azure_account.username, password: azure_account.password, base_uri: base_uri }
    end

    def teams
      HTTParty.get("#{@connection_parameters[:base_uri]}/teams?api-version=6.1",
                   basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] })
    end

    def projects
      HTTParty.get("#{@connection_parameters[:base_uri]}/projects?api-version=6.1",
                   basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] })
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      Rails.logger.error(e)
      {}
    end

    def work_items_ids(product)
      HTTParty.post("#{@connection_parameters[:base_uri]}/#{product.azure_product_config.product_id}//projects?api-version=6.1",
                    basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] })
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      Rails.logger.error(e)
      {}
    end
  end
end
