# frozen_string_literal: true

class CreateJiraPortfolioUnitConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :jira_portfolio_unit_configs do |t|
      t.integer :portfolio_unit_id, null: false, index: true

      t.string :jira_field_name, null: false

      t.timestamps
    end

    add_foreign_key :jira_portfolio_unit_configs, :portfolio_units, column: :portfolio_unit_id
  end
end
