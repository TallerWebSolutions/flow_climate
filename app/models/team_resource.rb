# frozen_string_literal: true

# == Schema Information
#
# Table name: team_resources
#
#  id            :bigint           not null, primary key
#  resource_name :string           not null
#  resource_type :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :integer          not null
#
# Indexes
#
#  index_team_resources_on_company_id     (company_id)
#  index_team_resources_on_resource_name  (resource_name)
#  index_team_resources_on_resource_type  (resource_type)
#
# Foreign Keys
#
#  fk_rails_0e82f4e026  (company_id => companies.id)
#

class TeamResource < ApplicationRecord
  enum resource_type: { cloud: 0, continuous_integration: 1, library_manager: 2, code_hosting_platform: 3 }

  belongs_to :company
  has_many :team_resource_allocations, dependent: :destroy

  validates :company, :resource_type, presence: true
end
