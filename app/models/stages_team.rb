# frozen_string_literal: true

# == Schema Information
#
# Table name: stages_teams
#
#  id         :integer          not null, primary key
#  stage_id   :integer          not null
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stages_teams_on_stage_id              (stage_id)
#  index_stages_teams_on_stage_id_and_team_id  (stage_id,team_id) UNIQUE
#  index_stages_teams_on_team_id               (team_id)
#

class StagesTeam < ApplicationRecord
  belongs_to :stage
  belongs_to :team
end
