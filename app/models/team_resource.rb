# frozen_string_literal: true

# == Schema Information
#
# Table name: team_resources
#
#  company_id    :integer          not null, indexed
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  resource_name :string           not null, indexed
#  resource_type :integer          not null, indexed
#  updated_at    :datetime         not null
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
