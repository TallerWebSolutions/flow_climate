# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id              :integer          not null, primary key
#  company_id      :integer          not null
#  name            :string           not null
#  monthly_payment :decimal(, )      not null
#  hours_per_month :integer          not null
#  active          :boolean          default(TRUE)
#  billable        :boolean          default(TRUE)
#  billable_type   :integer          default(1)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_team_members_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class TeamMember < ApplicationRecord
  enum billable_type: { outsourcing: 0, consulting: 1, training: 2 }

  belongs_to :company

  validates :name, :monthly_payment, :hours_per_month, presence: true
end
