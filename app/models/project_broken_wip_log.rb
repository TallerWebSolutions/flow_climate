# frozen_string_literal: true

# == Schema Information
#
# Table name: project_broken_wip_logs
#
#  id          :integer          not null, primary key
#  project_id  :integer          not null
#  project_wip :integer          not null
#  demands_ids :integer          not null, is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_project_broken_wip_logs_on_project_id  (project_id)
#

class ProjectBrokenWipLog < ApplicationRecord
  belongs_to :project

  validates :demands_ids, :project_wip, presence: true
end
