# frozen_string_literal: true

class AddModelNameToIntegrationError < ActiveRecord::Migration[5.1]
  def up
    change_table :integration_errors, bulk: true do |t|
      t.string :integratable_model_name, index: true
      t.remove :project_result_id
    end
  end

  def down
    change_table :integration_errors, bulk: true do |t|
      t.remove :integratable_model_name
      t.integer :project_result_id
    end

    add_foreign_key :integration_errors, :project_results, column: :project_result_id
  end
end
