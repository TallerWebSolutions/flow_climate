# frozen_string_literal: true

class RemoveNotNullForTeamInStage < ActiveRecord::Migration[5.2]
  def up
    change_table :stages, bulk: true do |t|
      t.change_default :stage_stream, 0
      t.change_default :stage_type, 0
    end
    change_column_null :stages, :team_id, true
  end

  def down
    execute('DELETE FROM stages WHERE team_id IS NULL')
    change_column_null :stages, :team_id, false
  end
end
