# frozen_string_literal: true

class CreateUserProjectRole < ActiveRecord::Migration[5.2]
  def change
    create_table :user_project_roles do |t|
      t.integer :user_id, null: false, index: true
      t.integer :project_id, null: false, index: true

      t.integer :role_in_project, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :user_project_roles, :users, column: :user_id
    add_foreign_key :user_project_roles, :projects, column: :project_id

    create_table :user_project_downloads do |t|
      t.integer :user_id, null: false, index: true
      t.integer :project_id, null: false, index: true

      t.integer :first_id_downloaded, null: false, index: true
      t.integer :last_id_downloaded, null: false, index: true

      t.timestamps
    end

    add_foreign_key :user_project_downloads, :users, column: :user_id
    add_foreign_key :user_project_downloads, :projects, column: :project_id
  end
end
