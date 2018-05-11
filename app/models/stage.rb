# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  commitment_point :boolean          default(FALSE)
#  company_id       :integer          not null
#  created_at       :datetime         not null
#  end_point        :boolean          default(FALSE)
#  id               :bigint(8)        not null, primary key
#  integration_id   :string           not null, indexed
#  name             :string           not null, indexed
#  order            :integer          default(0), not null
#  queue            :boolean          default(FALSE)
#  stage_stream     :integer          not null
#  stage_type       :integer          not null
#  updated_at       :datetime         not null
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
  enum stage_type: { backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7 }
  enum stage_stream: { upstream: 0, downstream: 1 }

  belongs_to :company

  has_many :stage_project_configs, dependent: :destroy
  has_many :projects, through: :stage_project_configs
  has_many :demand_transitions, dependent: :restrict_with_error

  validates :integration_id, :name, :stage_type, :stage_stream, presence: true

  def add_project!(project)
    projects << project unless projects.include?(project)
    save
  end

  def remove_project!(project)
    projects.delete(project) if projects.include?(project)
    save
  end
end
