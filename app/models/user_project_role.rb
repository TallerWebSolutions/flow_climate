# frozen_string_literal: true

# == Schema Information
#
# Table name: user_project_roles
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  project_id      :integer          not null, indexed
#  role_in_project :integer          default("user"), not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null, indexed
#
# Indexes
#
#  index_user_project_roles_on_project_id  (project_id)
#  index_user_project_roles_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_4bed04fd76  (user_id => users.id)
#  fk_rails_7402a518b4  (project_id => projects.id)
#

class UserProjectRole < ApplicationRecord
  enum role_in_project: { user: 0, manager: 1, owner: 2 }

  belongs_to :user
  belongs_to :project

  validates :user, :project, :role_in_project, presence: true
end
