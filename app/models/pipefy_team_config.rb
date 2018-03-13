# frozen_string_literal: true

# == Schema Information
#
# Table name: pipefy_team_configs
#
#  id             :integer          not null, primary key
#  team_id        :integer          not null
#  integration_id :string           not null
#  username       :string           not null
#  member_type    :integer          default("developer")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_pipefy_team_configs_on_integration_id  (integration_id)
#  index_pipefy_team_configs_on_team_id         (team_id)
#  index_pipefy_team_configs_on_username        (username)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#

class PipefyTeamConfig < ApplicationRecord
  enum member_type: { developer: 0, analyst: 1, designer: 2, customer: 3 }
  belongs_to :team

  validates :team, :integration_id, :username, presence: true
end
