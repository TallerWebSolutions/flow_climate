# frozen_string_literal: true

# == Schema Information
#
# Table name: user_project_roles
#
#  id              :bigint           not null, primary key
#  role_in_project :integer          default("team"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_user_project_roles_on_project_id              (project_id)
#  index_user_project_roles_on_user_id                 (user_id)
#  index_user_project_roles_on_user_id_and_project_id  (user_id,project_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_4bed04fd76  (user_id => users.id)
#  fk_rails_7402a518b4  (project_id => projects.id)
#

class UserProjectRole < ApplicationRecord
  enum :role_in_project, { team: 0, manager: 1, customer: 2 }

  belongs_to :user
  belongs_to :project

  validates :role_in_project, presence: true
  validates :user, uniqueness: { scope: :project }
end
