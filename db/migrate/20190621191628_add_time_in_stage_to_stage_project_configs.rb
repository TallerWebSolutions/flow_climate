# frozen_string_literal: true

class AddTimeInStageToStageProjectConfigs < ActiveRecord::Migration[5.2]
  def up
    change_table :stage_project_configs, bulk: true do |t|
      t.integer :max_seconds_in_stage, default: 0
    end
  end

  def down
    change_table :stage_project_configs, bulk: true do |t|
      t.remove :max_seconds_in_stage
    end
  end
end
