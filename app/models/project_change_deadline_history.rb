# frozen_string_literal: true

# == Schema Information
#
# Table name: project_change_deadline_histories
#
#  id            :integer          not null, primary key
#  project_id    :integer          not null
#  user_id       :integer          not null
#  previous_date :date
#  new_date      :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_project_change_deadline_histories_on_project_id  (project_id)
#  index_project_change_deadline_histories_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

class ProjectChangeDeadlineHistory < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :project, :user, :previous_date, :new_date, presence: true
end
