# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_custom_fields
#
#  id                :bigint           not null, primary key
#  custom_field_name :string           not null
#  custom_field_type :integer          default("project_name"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  azure_account_id  :integer          not null
#
# Foreign Keys
#
#  fk_rails_4fe176e72d  (azure_account_id => azure_accounts.id)
#
module Azure
  class AzureCustomField < ApplicationRecord
    enum custom_field_type: { project_name: 0, team_name: 1, epic_name: 2 }

    belongs_to :azure_account, class_name: 'Azure::AzureAccount'

    validates :custom_field_name, :custom_field_type, presence: true
  end
end
