# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :team_members do |t|
      t.integer :company_id, null: false, index: true
      t.string :name, null: false
      t.decimal :monthly_payment, null: false
      t.integer :hours_per_month, null: false
      t.boolean :active, default: true
      t.boolean :billable, default: true
      t.integer :billable_type, default: true

      t.timestamps
    end

    add_foreign_key :team_members, :companies, column: :company_id
  end
end
