# frozen_string_literal: true

# == Schema Information
#
# Table name: project_change_deadline_histories
#
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  new_date      :date
#  previous_date :date
#  project_id    :integer          not null, indexed
#  updated_at    :datetime         not null
#  user_id       :integer          not null, indexed
#
# Indexes
#
#  index_project_change_deadline_histories_on_project_id  (project_id)
#  index_project_change_deadline_histories_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_1f60eef53a  (project_id => projects.id)
#  fk_rails_7e0b9bce8f  (user_id => users.id)
#

class ProjectChangeDeadlineHistory < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :project, :user, :previous_date, :new_date, presence: true
end
