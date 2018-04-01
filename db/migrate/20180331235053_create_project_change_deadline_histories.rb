# frozen_string_literal: true

class CreateProjectChangeDeadlineHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :project_change_deadline_histories do |t|
      t.integer :project_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.date :previous_date
      t.date :new_date

      t.timestamps
    end

    add_foreign_key :project_change_deadline_histories, :projects, column: :project_id
    add_foreign_key :project_change_deadline_histories, :users, column: :user_id
  end
end
