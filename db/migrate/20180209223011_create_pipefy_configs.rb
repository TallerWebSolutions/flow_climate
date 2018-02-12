# frozen_string_literal: true

class CreatePipefyConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :pipefy_configs do |t|
      t.integer :project_id, null: false, index: true
      t.integer :team_id, null: false, index: true
      t.string :pipe_id, null: false

      t.timestamps
    end

    add_foreign_key :pipefy_configs, :projects, column: :project_id
    add_foreign_key :pipefy_configs, :teams, column: :team_id
  end
end
