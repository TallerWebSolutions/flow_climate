# frozen_string_literal: true

class AddCompanyToStage < ActiveRecord::Migration[5.1]
  def change
    add_column :stages, :company_id, :integer, null: false
    add_index :stages, :company_id
    add_foreign_key :stages, :companies, column: :company_id
  end
end
