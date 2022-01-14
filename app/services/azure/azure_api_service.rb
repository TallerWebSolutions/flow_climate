# frozen_string_literal: true

module Azure
  class AzureApiService
    attr_reader :connection_parameters

    def initialize(azure_account)
      base_uri = "#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}"
      @connection_parameters = { username: azure_account.username, password: azure_account.password, base_uri: base_uri }
    end

    def teams
      HTTParty.get("#{@connection_parameters[:base_uri]}/_apis/teams?api-version=6.1-preview.3",
                   basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] },
                   headers: { 'Content-Type' => 'application/json' })
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      Rails.logger.error(e)
      {}
    end

    def work_items_ids(azure_product_config)
      query = { 'query' => 'SELECT Id FROM WorkItems' }
      HTTParty.post("#{@connection_parameters[:base_uri]}/#{azure_product_config.azure_team.azure_project.project_id}/#{azure_product_config.azure_team.team_id}/_apis/wit/wiql?api-version=6.0",
                    body: query.to_json,
                    basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] },
                    headers: { 'Content-Type' => 'application/json' })
    rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
      Rails.logger.error(e)
      {}
    end
  end
end
