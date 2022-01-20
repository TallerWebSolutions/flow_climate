# frozen_string_literal: true

Fabricator(:azure_product_config, from: 'Azure::AzureProductConfig') do
  azure_account
  product
end
