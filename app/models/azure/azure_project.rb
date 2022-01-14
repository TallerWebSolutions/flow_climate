# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_projects
#
#  id            :bigint           not null, primary key
#  project_name  :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  azure_team_id :integer          not null
#  project_id    :string           not null
#
# Indexes
#
#  index_azure_projects_on_azure_team_id  (azure_team_id)
#
# Foreign Keys
#
#  fk_rails_f1091df050  (azure_team_id => azure_teams.id)
#
module Azure
  class AzureProject < ApplicationRecord
    belongs_to :azure_team, class_name: 'Azure::AzureTeam'

    validates :project_name, :project_id, presence: true
  end
end
