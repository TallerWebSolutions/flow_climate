# frozen_string_literal: true

Fabricator(:azure_account, from: 'Azure::AzureAccount') do
  company
  username { 'foo' }
  password { 'bar' }
  azure_organization { 'bla' }
end
