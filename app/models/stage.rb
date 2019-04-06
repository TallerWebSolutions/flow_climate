# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  commitment_point    :boolean          default(FALSE)
#  company_id          :integer          not null
#  created_at          :datetime         not null
#  end_point           :boolean          default(FALSE)
#  id                  :bigint(8)        not null, primary key
#  integration_id      :string           not null, indexed
#  integration_pipe_id :string
#  name                :string           not null, indexed
#  order               :integer          default(0), not null
#  queue               :boolean          default(FALSE)
#  stage_stream        :integer          not null
#  stage_type          :integer          not null
#  team_id             :integer
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_stages_on_integration_id  (integration_id)
#  index_stages_on_name            (name)
#
# Foreign Keys
#
#  fk_rails_c4e2c44248  (team_id => teams.id)
#  fk_rails_ffd4cca0d4  (company_id => companies.id)
#

class Stage < ApplicationRecord
  enum stage_type: { backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7, archived: 8 }
  enum stage_stream: { upstream: 0, downstream: 1, out_stream: 2 }

  belongs_to :company
  belongs_to :team

  has_many :stage_project_configs, dependent: :destroy
  has_many :projects, through: :stage_project_configs
  has_many :demand_transitions, dependent: :restrict_with_error
  has_many :demand_blocks, dependent: :restrict_with_error

  validates :integration_id, :name, :stage_type, :stage_stream, presence: true

  def add_project!(project)
    projects << project unless projects.include?(project)
    save
  end

  def remove_project!(project)
    projects.delete(project) if projects.include?(project)
    save
  end

  def first_end_stage_in_pipe?(demand)
    first_done_stage_in_pipe(demand)&.id == id
  end

  def before_end_point?(demand)
    return true if first_done_stage_in_pipe(demand).blank?

    order < first_done_stage_in_pipe(demand).order
  end

  private

  def first_done_stage_in_pipe(demand)
    return company.stages.where(integration_pipe_id: integration_pipe_id, end_point: true, stage_stream: :downstream).order(:order).first if demand.downstream_demand?

    company.stages.where(integration_pipe_id: integration_pipe_id, end_point: true).order(:order).first
  end
end
