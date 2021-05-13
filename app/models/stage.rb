# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  id                  :bigint           not null, primary key
#  commitment_point    :boolean          default(FALSE)
#  end_point           :boolean          default(FALSE)
#  name                :string           not null
#  order               :integer          default(0), not null
#  queue               :boolean          default(FALSE)
#  stage_stream        :integer          default("upstream"), not null
#  stage_type          :integer          default("backlog"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer          not null
#  integration_id      :string           not null
#  integration_pipe_id :string
#
# Indexes
#
#  index_stages_on_integration_id  (integration_id)
#  index_stages_on_name            (name)
#
# Foreign Keys
#
#  fk_rails_ffd4cca0d4  (company_id => companies.id)
#

class Stage < ApplicationRecord
  enum stage_type: { backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7, archived: 8 }
  enum stage_stream: { upstream: 0, downstream: 1, out_stream: 2 }

  belongs_to :company

  has_and_belongs_to_many :teams

  has_many :stage_project_configs, dependent: :destroy
  has_many :projects, through: :stage_project_configs
  has_many :demand_transitions, dependent: :restrict_with_error
  has_many :demand_blocks, dependent: :restrict_with_error
  has_many :current_demands, class_name: 'Demand', foreign_key: :current_stage_id, inverse_of: :current_stage, dependent: :nullify

  validates :integration_id, :name, :stage_type, :stage_stream, presence: true

  def add_project(project)
    projects << project unless projects.include?(project)
    save
  end

  def remove_project(project)
    projects.delete(project) if projects.include?(project)
    save
  end

  def add_team(team)
    teams << team unless teams.include?(team)
    save
  end

  def remove_team(team)
    teams.delete(team) if teams.include?(team)
    save
  end

  def first_end_stage_in_pipe?
    first_done_stage_in_pipe&.id == id
  end

  def before_end_point?
    return true if first_done_stage_in_pipe.blank?

    order < first_done_stage_in_pipe.order
  end

  def total_seconds_in
    demand_transitions.sum(&:total_seconds_in_transition)
  end

  private

  def first_done_stage_in_pipe
    company.stages.where('stages.integration_pipe_id = :integration_pipe_id AND (stages.order IS NULL OR stages.order >= 0) AND stages.end_point = true', integration_pipe_id: integration_pipe_id).order(:order).first
  end
end
