# frozen_string_literal: true

# == Schema Information
#
# Table name: project_additional_hours
#
#  id         :bigint           not null, primary key
#  hours      :integer          default(0), not null
#  hours_type :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer          not null
#
# Indexes
#
#  index_project_additional_hours_on_hours_type  (hours_type)
#  index_project_additional_hours_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_51a0d1b6fa  (project_id => projects.id)
#
class ProjectAdditionalHour < ApplicationRecord
  belongs_to :project

  validates :hours_type, :hours, presence: true
end
