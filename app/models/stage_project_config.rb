# frozen_string_literal: true

# == Schema Information
#
# Table name: stage_project_configs
#
#  compute_effort        :boolean          default(FALSE)
#  created_at            :datetime         not null
#  id                    :bigint(8)        not null, primary key
#  management_percentage :integer          default(0)
#  pairing_percentage    :integer          default(0)
#  project_id            :integer          not null, indexed, indexed => [stage_id]
#  stage_id              :integer          not null, indexed => [project_id], indexed
#  stage_percentage      :integer          default(0)
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_stage_project_configs_on_project_id               (project_id)
#  index_stage_project_configs_on_project_id_and_stage_id  (project_id,stage_id) UNIQUE
#  index_stage_project_configs_on_stage_id                 (stage_id)
#
# Foreign Keys
#
#  fk_rails_713ceb31a3  (project_id => projects.id)
#  fk_rails_b25c287b60  (stage_id => stages.id)
#

class StageProjectConfig < ApplicationRecord
  belongs_to :project
  belongs_to :stage

  validates :project, :stage, presence: true
  validates :project, uniqueness: { scope: :stage, message: I18n.t('stage_project_config.validations.stage_project_unique.message') }
end
