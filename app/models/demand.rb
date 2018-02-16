# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                :integer          not null, primary key
#  project_result_id :integer          not null
#  demand_id         :string           not null
#  effort            :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_type       :integer
#  demand_url        :string
#  commitment_date   :datetime
#  end_date          :datetime
#  created_date      :datetime         not null
#  url               :string
#
# Indexes
#
#  index_demands_on_project_result_id  (project_result_id)
#

class Demand < ApplicationRecord
  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4 }

  belongs_to :project_result, counter_cache: true

  validates :project_result, :created_date, :demand_id, :effort, presence: true
end
