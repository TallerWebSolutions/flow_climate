# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_projects
#
#  id            :integer          not null, primary key
#  azure_team_id :integer          not null
#  project_id    :string           not null
#  project_name  :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_azure_projects_on_azure_team_id  (azure_team_id)
#

module Azure
  class AzureProject < ApplicationRecord
    belongs_to :azure_team, class_name: 'Azure::AzureTeam'

    validates :project_name, :project_id, presence: true
  end
end
