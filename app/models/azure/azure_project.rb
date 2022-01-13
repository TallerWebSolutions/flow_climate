# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_projects
#
#  id                      :bigint           not null, primary key
#  project_name            :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  azure_product_config_id :integer          not null
#  project_id              :string           not null
#
# Indexes
#
#  index_azure_projects_on_azure_product_config_id  (azure_product_config_id)
#
# Foreign Keys
#
#  fk_rails_fede69488a  (azure_product_config_id => azure_product_configs.id)
#
module Azure
  class AzureProject < ApplicationRecord
    belongs_to :azure_product_config, class_name: 'Azure::AzureProductConfig'

    validates :project_name, :project_id, presence: true
  end
end
