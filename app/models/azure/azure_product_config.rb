# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_product_configs
#
#  id               :integer          not null, primary key
#  product_id       :integer          not null
#  azure_account_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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

    has_one :azure_team, class_name: 'Azure::AzureTeam', dependent: :destroy
  end
end
