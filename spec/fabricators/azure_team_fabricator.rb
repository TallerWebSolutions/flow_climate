# frozen_string_literal: true

Fabricator(:azure_team, from: 'Azure::AzureTeam') do
  azure_product_config
  team_name 'team_name'
  team_id 'team_id'
end
