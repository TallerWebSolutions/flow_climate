# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  id                :integer          not null, primary key
#  integration_id    :string           not null
#  name              :string           not null
#  stage_type        :integer          not null
#  stage_stream      :integer          not null
#  commitment_point  :boolean          default(FALSE)
#  end_point         :boolean          default(FALSE)
#  queue             :boolean          default(FALSE)
#  compute_effort    :boolean          default(FALSE)
#  percentage_effort :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :integer          not null
#
# Indexes
#
#  index_stages_on_integration_id  (integration_id)
#  index_stages_on_name            (name)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class Stage < ApplicationRecord
  enum stage_type: { backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7 }
  enum stage_stream: { upstream: 0, downstream: 1 }

  belongs_to :company

  has_and_belongs_to_many :projects
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
