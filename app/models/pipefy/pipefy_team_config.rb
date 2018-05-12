# frozen_string_literal: true

# == Schema Information
#
# Table name: pipefy_team_configs
#
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  integration_id :string           not null, indexed
#  member_type    :integer          default("developer")
#  team_id        :integer          not null, indexed
#  updated_at     :datetime         not null
#  username       :string           not null, indexed
#
# Indexes
#
#  index_pipefy_team_configs_on_integration_id  (integration_id)
#  index_pipefy_team_configs_on_team_id         (team_id)
#  index_pipefy_team_configs_on_username        (username)
#
# Foreign Keys
#
#  fk_rails_6b009afec0  (team_id => teams.id)
#

module Pipefy
  class PipefyTeamConfig < ApplicationRecord
    enum member_type: { developer: 0, analyst: 1, designer: 2, customer: 3 }
    belongs_to :team

    validates :team, :integration_id, :username, presence: true
  end
end
