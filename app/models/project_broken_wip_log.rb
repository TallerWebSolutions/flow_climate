# frozen_string_literal: true

# == Schema Information
#
# Table name: project_broken_wip_logs
#
#  id          :bigint           not null, primary key
#  demands_ids :integer          not null, is an Array
#  project_wip :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :integer          not null
#
# Indexes
#
#  index_project_broken_wip_logs_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_79ce1654a8  (project_id => projects.id)
#

class ProjectBrokenWipLog < ApplicationRecord
  belongs_to :project

  validates :demands_ids, :project_wip, presence: true
end
