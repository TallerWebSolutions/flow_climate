# frozen_string_literal: true

# == Schema Information
#
# Table name: project_weekly_costs
#
#  created_at             :datetime         not null
#  date_beggining_of_week :date
#  id                     :bigint(8)        not null, primary key
#  monthly_cost_value     :decimal(, )
#  project_id             :integer          indexed
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_project_weekly_costs_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_eafbb59099  (project_id => projects.id)
#

class ProjectWeeklyCost < ApplicationRecord
  belongs_to :project

  validates :project, :monthly_cost_value, presence: true
end
