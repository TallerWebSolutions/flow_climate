# frozen_string_literal: true

class AddCompanyToStage < ActiveRecord::Migration[5.1]
  def change
    add_column :stages, :company_id, :integer, index: true
    add_foreign_key :stages, :companies, column: :company_id
    Stage.all.each { |s| s.update(company_id: 1) }
    change_column_null :stages, :company_id, false
  end
end
