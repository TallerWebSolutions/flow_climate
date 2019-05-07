# frozen_string_literal: true

class ChangeColumnNullTeamInStage < ActiveRecord::Migration[5.2]
  def change
    change_column_null :stages, :team_id, false
  end
end
