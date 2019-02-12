# frozen_string_literal: true

class AddSlugToDemands < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :slug, :string
    add_index :demands, :slug, unique: [:company_id]

    remove_index :demands, %i[demand_id project_id]

    change_table :demands, bulk: true do |t|
      t.integer :company_id, index: true
    end

    Demand.all.each { |demand| demand.update(company_id: demand.company.id) }

    change_column_null :demands, :company_id, false

    add_index :demands, %i[demand_id company_id], unique: true
  end
end
