# frozen_string_literal: true

class CreateTeamResources < ActiveRecord::Migration[6.0]
  def change
    create_table :team_resources do |t|
      t.integer :company_id, null: false, index: true
      t.integer :resource_type, null: false, index: true
      t.string :resource_name, null: false, index: true

      t.timestamps
    end

    add_foreign_key :team_resources, :companies, column: :company_id

    create_table :team_resource_allocations do |t|
      t.integer :team_resource_id, null: false, index: true
      t.integer :team_id, null: false, index: true

      t.decimal :monthly_payment, null: false

      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end

    add_foreign_key :team_resource_allocations, :team_resources, column: :team_resource_id
    add_foreign_key :team_resource_allocations, :teams, column: :team_id
  end
end
