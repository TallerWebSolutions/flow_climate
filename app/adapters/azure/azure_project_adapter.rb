# frozen_string_literal: true

module Azure
  class AzureProjectAdapter < Azure::AzureAdapter
    def products
      azure_teams = client.teams

      products = []
      if azure_teams.respond_to?(:code) && azure_teams.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{azure_teams.code}")
      else
        azure_teams['value'].each do |azure_json_value|
          product_config = process_azure_product(azure_json_value)
          products << product_config.product unless products.include?(product_config.product)
        end
      end

      products
    end

    private

    def process_azure_product(azure_value)
      product_name = azure_value['projectName']
      product_id = azure_value['projectId']
      team_name = azure_value['name']
      team_id = azure_value['id']
      company = @azure_account.company

      product = Product.where(name: product_name, company: company).first_or_create

      product_config = Azure::AzureProductConfig.where(azure_account: @azure_account, product: product).first_or_create

      azure_team = Azure::AzureTeam.where(team_name: team_name, team_id: team_id, azure_product_config: product_config).first_or_create
      Azure::AzureProject.where(project_name: product_name, project_id: product_id, azure_team: azure_team).first_or_create

      product_config
    end
  end
end
