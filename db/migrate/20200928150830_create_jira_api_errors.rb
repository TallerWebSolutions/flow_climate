# frozen_string_literal: true

class CreateJiraApiErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :jira_api_errors do |t|
      t.integer :demand_id, index: true, null: false
      t.boolean :processed, default: false, null: false

      t.timestamps
    end

    add_foreign_key :jira_api_errors, :demands, column: :demand_id
  end
end
