# frozen_string_literal: true

class CreateFlowImpacts < ActiveRecord::Migration[5.2]
  def change
    create_table :flow_impacts do |t|
      t.integer :project_id, null: false, index: true
      t.integer :demand_id, index: true

      t.integer :impact_type, null: false, index: true
      t.string :impact_description, null: false

      t.datetime :start_date, null: false
      t.datetime :end_date

      t.timestamps
    end

    add_foreign_key :flow_impacts, :projects, column: :project_id
    add_foreign_key :flow_impacts, :demands, column: :demand_id
  end
end
