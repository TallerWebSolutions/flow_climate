# frozen_string_literal: true

# == Schema Information
#
# Table name: stages
#
#  id               :integer          not null, primary key
#  integration_id   :string           not null
#  name             :string           not null
#  stage_type       :integer          not null
#  stage_stream     :integer          not null
#  commitment_point :boolean          default(FALSE)
#  end_point        :boolean          default(FALSE)
#  queue            :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_stages_on_integration_id  (integration_id)
#  index_stages_on_name            (name)
#

class Stage < ApplicationRecord
  enum stage_type: { design: 0, analysis: 1, development: 2, test: 3, homologation: 4, ready_to_deploy: 5, deployed: 6 }
  enum stage_stream: { upstream: 0, downstream: 1 }

  has_and_belongs_to_many :projects
  has_many :demand_transitions, dependent: :restrict_with_error

  validates :integration_id, :name, :stage_type, :stage_stream, presence: true
end
