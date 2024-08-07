# frozen_string_literal: true

class CreateStageProjectConfigs < ActiveRecord::Migration[5.2]
  def up
    create_table :stage_project_configs do |t|
      t.integer :project_id, null: false, index: true
      t.integer :stage_id, null: false, index: true

      t.boolean :compute_effort, default: false, null: false

      t.integer :stage_percentage
      t.integer :management_percentage
      t.integer :pairing_percentage

      t.timestamps
    end

    add_foreign_key :stage_project_configs, :projects, column: :project_id
    add_foreign_key :stage_project_configs, :stages, column: :stage_id

    add_index :stage_project_configs, %i[project_id stage_id], unique: true

    execute('INSERT INTO stage_project_configs(stage_id, project_id, created_at, updated_at) SELECT stage_id, project_id, created_at, updated_at FROM projects_stages;')
    execute('DROP TABLE projects_stages;')

    change_table :stages, bulk: true do |t|
      t.remove :compute_effort
      t.remove :percentage_effort
    end
  end

  def down
    create_table :projects_stages do |t|
      t.integer :project_id, null: false, index: true
      t.integer :stage_id, null: false, index: true

      t.timestamps
    end
    execute('INSERT INTO projects_stages(stage_id, project_id, created_at, updated_at) SELECT stage_id, project_id, created_at, updated_at FROM stage_project_configs;')

    change_table :stages, bulk: true do |t|
      t.boolean :compute_effort, null: false, default: false
      t.decimal :percentage_effort
    end

    drop_table :stage_project_configs
  end
end
