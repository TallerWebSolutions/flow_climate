# frozen_string_literal: true

Fabricator(:azure_product_config, from: 'Azure::AzureProductConfig') do
  azure_product_name 'product name'
  azure_product_id 'product id'
  customer
  product
end
