# frozen_string_literal: true

class AddProjectIdToIntegrationErrors < ActiveRecord::Migration[5.1]
  def change
    add_column :integration_errors, :project_id, :integer, index: true
    add_column :integration_errors, :project_result_id, :integer, index: true

    add_foreign_key :integration_errors, :projects, column: :project_id
    add_foreign_key :integration_errors, :project_results, column: :project_result_id
  end
end
