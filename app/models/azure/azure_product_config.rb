# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_product_configs
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  azure_account_id :bigint           not null
#  product_id       :bigint           not null
#
# Indexes
#
#  index_azure_product_configs_on_azure_account_id  (azure_account_id)
#  index_azure_product_configs_on_product_id        (product_id)
#
module Azure
  class AzureProductConfig < ApplicationRecord
    belongs_to :product
    belongs_to :azure_account

    has_many :azure_projects, class_name: 'Azure::AzureProject', dependent: :destroy
    has_many :azure_teams, class_name: 'Azure::AzureTeam', dependent: :destroy
  end
end
