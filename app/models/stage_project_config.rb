# frozen_string_literal: true

# == Schema Information
#
# Table name: stage_project_configs
#
#  id                    :bigint           not null, primary key
#  compute_effort        :boolean          default(FALSE)
#  management_percentage :integer          default(0)
#  max_seconds_in_stage  :integer          default(0)
#  pairing_percentage    :integer          default(0)
#  stage_percentage      :integer          default(0)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  project_id            :integer          not null
#  stage_id              :integer          not null
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

  def management_percentage_decimal
    management_percentage / 100.0
  end

  def pairing_percentage_decimal
    return 0 if pairing_percentage.blank?

    pairing_percentage / 100.0
  end

  def stage_percentage_decimal
    stage_percentage / 100.0
  end
end
