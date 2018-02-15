# frozen_string_literal: true

# == Schema Information
#
# Table name: pipefy_configs
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  team_id    :integer          not null
#  pipe_id    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_pipefy_configs_on_project_id  (project_id)
#  index_pipefy_configs_on_team_id     (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (team_id => teams.id)
#

class PipefyConfig < ApplicationRecord
  belongs_to :company
  belongs_to :project
  belongs_to :team

  validates :company, :project, :pipe_id, :team, presence: true

  delegate :name, to: :team, prefix: true
  delegate :full_name, to: :project, prefix: true
end
