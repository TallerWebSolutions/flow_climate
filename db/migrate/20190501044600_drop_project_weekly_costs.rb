# frozen_string_literal: true

class DropProjectWeeklyCosts < ActiveRecord::Migration[5.2]
  def up
    drop_table :project_weekly_costs
  end

  def down
    create_table :project_weekly_costs do |t|
      t.integer :project_id, index: true
      t.date :date_beggining_of_week
      t.decimal :monthly_cost_value

      t.timestamps
    end

    add_foreign_key :project_weekly_costs, :projects, column: :project_id
  end
end
