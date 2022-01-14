# frozen_string_literal: true

Fabricator(:azure_custom_field, from: 'Azure::AzureCustomField') do
  azure_account
  custom_field_type 0
  custom_field_name 'ProjectName'
end
