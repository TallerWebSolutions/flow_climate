# frozen_string_literal: true

class AddProjectIdToIntegrationErrors < ActiveRecord::Migration[5.1]
  def up
    change_table :integration_errors, bulk: true do |t|
      t.integer :project_id, index: true
      t.integer :project_result_id, index: true
    end

    add_foreign_key :integration_errors, :projects, column: :project_id
    add_foreign_key :integration_errors, :project_results, column: :project_result_id
  end

  def down
    remove_foreign_key :integration_errors, :projects
    remove_foreign_key :integration_errors, :project_results

    change_table :integration_errors, bulk: true do |t|
      t.remove :project_id
      t.remove :project_result_id
    end
  end
end
