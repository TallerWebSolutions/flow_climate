# frozen_string_literal: true

# == Schema Information
#
# Table name: pipefy_configs
#
#  active     :boolean          default(TRUE)
#  company_id :integer          not null
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  pipe_id    :string           not null
#  project_id :integer          not null, indexed
#  team_id    :integer          not null, indexed
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pipefy_configs_on_project_id  (project_id)
#  index_pipefy_configs_on_team_id     (team_id)
#
# Foreign Keys
#
#  fk_rails_0732eff170  (project_id => projects.id)
#  fk_rails_3895e626a7  (company_id => companies.id)
#  fk_rails_429f1ebe04  (team_id => teams.id)
#

module Pipefy
  class PipefyConfig < ApplicationRecord
    belongs_to :company
    belongs_to :project
    belongs_to :team

    validates :company, :project, :pipe_id, :team, presence: true

    delegate :name, to: :team, prefix: true
    delegate :full_name, to: :project, prefix: true
  end
end
