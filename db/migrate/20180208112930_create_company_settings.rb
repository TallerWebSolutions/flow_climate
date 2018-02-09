# frozen_string_literal: true

class CreateCompanySettings < ActiveRecord::Migration[5.1]
  def change
    create_table :company_settings do |t|
      t.integer :company_id, null: false, index: true
      t.integer :max_active_parallel_projects, null: false
      t.decimal :max_flow_pressure, null: false

      t.timestamps
    end

    add_foreign_key :company_settings, :companies, column: :company_id
  end
end
