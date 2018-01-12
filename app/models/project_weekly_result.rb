# frozen_string_literal: true

# == Schema Information
#
# Table name: project_weekly_results
#
#  id                    :integer          not null, primary key
#  project_id            :integer          not null
#  result_date           :date             not null
#  qty_hours_upstream    :integer
#  qty_hours_downstream  :integer
#  throughput            :integer          not null
#  qty_bugs_opened       :integer          not null
#  qty_bugs_closed       :integer          not null
#  qty_hours_bug         :integer          not null
#  leadtime              :decimal(, )
#  histogram_first_mode  :decimal(, )
#  histogram_second_mode :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_project_weekly_results_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#

class ProjectWeeklyResult < ApplicationRecord
  belongs_to :project

  validates :qty_hours_bug, :qty_bugs_closed, :qty_bugs_opened, :throughput, :result_date, presence: true
end
