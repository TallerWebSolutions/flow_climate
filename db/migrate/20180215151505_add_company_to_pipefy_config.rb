# frozen_string_literal: true

class AddCompanyToPipefyConfig < ActiveRecord::Migration[5.1]
  def change
    add_column :pipefy_configs, :company_id, :integer, null: false
    add_index :pipefy_configs, :company_id
    add_foreign_key :pipefy_configs, :companies, column: :company_id
  end
end
