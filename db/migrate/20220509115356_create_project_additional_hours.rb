# frozen_string_literal: true

class CreateProjectAdditionalHours < ActiveRecord::Migration[7.0]
  def change
    create_table :project_additional_hours do |t|
      t.integer :project_id, null: false, index: true
      t.integer :hours_type, null: false, default: 0, index: true
      t.float :hours, null: false, default: 0

      t.string :obs

      t.timestamps
    end

    add_foreign_key :project_additional_hours, :projects, column: :project_id
  end
end
