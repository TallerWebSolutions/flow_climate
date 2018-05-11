# frozen_string_literal: true

class CreateStageProjectConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :stage_project_configs do |t|
      t.integer :project_id, null: false, index: true
      t.integer :stage_id, null: false, index: true

      t.boolean :compute_effort, default: false

      t.integer :stage_percentage
      t.integer :management_percentage
      t.integer :pairing_percentage

      t.timestamps
    end

    add_foreign_key :stage_project_configs, :projects, column: :project_id
    add_foreign_key :stage_project_configs, :stages, column: :stage_id

    add_index :stage_project_configs, %i[project_id stage_id], unique: true

    remove_column :stages, :compute_effort, :boolean
    remove_column :stages, :percentage_effort, :decimal
  end
end
