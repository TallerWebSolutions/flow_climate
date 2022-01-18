# frozen_string_literal: true

module Azure
  class AzureApiService
    attr_reader :connection_parameters

    MAX_RETRIES = 3

    def initialize(azure_account)
      base_uri = "#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}"
      @connection_parameters = { username: azure_account.username, password: azure_account.password, base_uri: base_uri }
    end

    def teams
      retries = 0
      begin
        HTTParty.get("#{@connection_parameters[:base_uri]}/_apis/teams?api-version=6.1-preview.3",
                     basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] },
                     headers: { 'Content-Type' => 'application/json' })
      rescue Errno::ECONNREFUSED, Net::ReadTimeout, Errno::EHOSTUNREACH => e
        Rails.logger.error(e)
        if (retries += 1) < MAX_RETRIES
          Rails.logger.error("retrying #{retries}/#{MAX_RETRIES}")
          retry
        end
        {}
      end
    end

    def work_items_ids(azure_product_config)
      retries = 0
      begin
        query = { 'query' => 'SELECT Id FROM WorkItems' }
        HTTParty.post("#{@connection_parameters[:base_uri]}/#{azure_product_config.azure_team.azure_project.project_id}/#{azure_product_config.azure_team.team_id}/_apis/wit/wiql?api-version=6.0",
                      body: query.to_json,
                      basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] },
                      headers: { 'Content-Type' => 'application/json' })
      rescue Errno::ECONNREFUSED, Net::ReadTimeout, Errno::EHOSTUNREACH => e
        Rails.logger.error(e)
        if (retries += 1) < MAX_RETRIES
          Rails.logger.error("retrying #{retries}/#{MAX_RETRIES}")
          retry
        end
        {}
      end
    end

    def work_item(work_item_id, azure_project_id)
      retries = 0
      begin
        Rails.logger.info("processing work item ##{work_item_id}")
        HTTParty.get("#{@connection_parameters[:base_uri]}/#{azure_project_id}/_apis/wit/workitems/#{work_item_id}?$expand=all&api-version=6.1-preview.3",
                     basic_auth: { username: @connection_parameters[:username], password: @connection_parameters[:password] },
                     headers: { 'Content-Type' => 'application/json' })
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, Net::ReadTimeout => e
        error = "error -> #{e}\n[azure_item_id] #{work_item_id}"
        Rails.logger.error(error)
        if (retries += 1) < MAX_RETRIES
          Rails.logger.error("retrying #{retries}/#{MAX_RETRIES}")
          retry
        end
        {}
      end
    end
  end
end
