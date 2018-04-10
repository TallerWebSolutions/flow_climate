# frozen_string_literal: true

class AddModelNameToIntegrationError < ActiveRecord::Migration[5.1]
  def change
    add_column :integration_errors, :integratable_model_name, :string, index: true

    remove_column :integration_errors, :project_result_id, :integer
  end
end
