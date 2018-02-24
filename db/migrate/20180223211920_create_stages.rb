# frozen_string_literal: true

class CreateStages < ActiveRecord::Migration[5.1]
  def change
    create_table :stages do |t|
      t.string :integration_id, null: false, index: true
      t.string :name, null: false, index: true
      t.integer :stage_type, null: false
      t.integer :stage_stream, null: false
      t.boolean :commitment_point, default: false
      t.boolean :end_point, default: false
      t.boolean :queue, default: false

      t.timestamps
    end

    create_table :projects_stages do |t|
      t.integer :project_id, null: false, index: true
      t.integer :stage_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :projects_stages, :projects, column: :project_id, index: true
    add_foreign_key :projects_stages, :stages, column: :stage_id, index: true
  end
end
