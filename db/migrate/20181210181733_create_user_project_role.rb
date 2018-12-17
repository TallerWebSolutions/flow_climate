# frozen_string_literal: true

class CreateUserProjectRole < ActiveRecord::Migration[5.2]
  def change
    create_table :user_project_roles do |t|
      t.integer :user_id, null: false, index: true
      t.integer :project_id, null: false, index: true

      t.integer :role_in_project, default: 0, null: false

      t.timestamps
    end

    add_index :user_project_roles, %i[user_id project_id], unique: true

    add_foreign_key :user_project_roles, :users, column: :user_id
    add_foreign_key :user_project_roles, :projects, column: :project_id

    create_table :demand_data_processments do |t|
      t.integer :user_id, null: false, index: true

      t.string :project_key, null: false

      t.text :downloaded_content, null: false

      t.timestamps
    end

    add_foreign_key :demand_data_processments, :users, column: :user_id
  end
end
