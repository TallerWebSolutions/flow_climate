# frozen_string_literal: true

# == Schema Information
#
# Table name: stages_teams
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stage_id   :integer          not null
#  team_id    :integer          not null
#
# Indexes
#
#  index_stages_teams_on_stage_id              (stage_id)
#  index_stages_teams_on_stage_id_and_team_id  (stage_id,team_id) UNIQUE
#  index_stages_teams_on_team_id               (team_id)
#
# Foreign Keys
#
#  fk_rails_8d8a97b7b3  (team_id => teams.id)
#  fk_rails_cb288435d9  (stage_id => stages.id)
#
class StagesTeam < ApplicationRecord
  belongs_to :stage
  belongs_to :team
end
