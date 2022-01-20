# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_accounts
#
#  id                    :bigint           not null, primary key
#  azure_organization    :string           not null
#  azure_work_item_query :string
#  encrypted_password    :string           not null
#  username              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  company_id            :bigint           not null
#
# Indexes
#
#  index_azure_accounts_on_company_id  (company_id)
#
module Azure
  class AzureAccount < ApplicationRecord
    belongs_to :company
    has_many :azure_product_configs, class_name: 'Azure::AzureProductConfig', dependent: :destroy
    has_many :azure_custom_fields, class_name: 'Azure::AzureCustomField', dependent: :destroy

    validates :azure_organization, :username, :encrypted_password, presence: true

    def password
      Security::EncryptionService.decrypt(encrypted_password)
    end

    def password=(value)
      self.encrypted_password = Security::EncryptionService.encrypt(value)
    end
  end
end
