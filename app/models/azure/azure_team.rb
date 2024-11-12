# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_teams
#
#  id                      :integer          not null, primary key
#  azure_product_config_id :integer          not null
#  team_id                 :string           not null
#  team_name               :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_azure_teams_on_azure_product_config_id  (azure_product_config_id)
#

module Azure
  class AzureTeam < ApplicationRecord
    belongs_to :azure_product_config, class_name: 'Azure::AzureProductConfig'
    has_one :azure_project, class_name: 'Azure::AzureProject', dependent: :destroy

    validates :team_name, :team_id, presence: true
  end
end
