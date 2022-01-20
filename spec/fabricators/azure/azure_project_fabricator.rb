# frozen_string_literal: true

Fabricator(:azure_project, from: 'Azure::AzureProject') do
  azure_team
  project_name 'project_name'
  project_id 'project_id'
end
