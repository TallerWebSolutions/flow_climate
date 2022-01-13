# frozen_string_literal: true

module Azure
  class AzureProjectAdapter
    include Singleton

    def projects(azure_account)
      azure_api_return = AzureApiService.new(azure_account).projects

      products = []
      if azure_api_return.respond_to?(:code) && azure_api_return.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{azure_api_return.code}")
      else
        projects_hash = JSON.parse(azure_api_return)
        projects_hash['value'].each do |azure_value|
          product_name = azure_value['name']
          product_id = azure_value['id']

          product_config = Azure::AzureProductConfig.find_by(azure_product_id: product_id, azure_product_name: product_name, azure_account: azure_account)

          products << product_config.product
        end
      end

      products
    end
  end
end
