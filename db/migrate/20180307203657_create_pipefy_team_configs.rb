# frozen_string_literal: true

class CreatePipefyTeamConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :pipefy_team_configs do |t|
      t.integer :team_id, null: false, index: true
      t.string :integration_id, null: false, index: true
      t.string :username, null: false, index: true
      t.integer :member_type, default: 0

      t.timestamps
    end

    add_foreign_key :pipefy_team_configs, :teams, column: :team_id
  end
end
