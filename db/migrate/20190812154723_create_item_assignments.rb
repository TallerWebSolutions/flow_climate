# frozen_string_literal: true

class CreateItemAssignments < ActiveRecord::Migration[5.2]
  def change
    rename_table :demands_team_members, :item_assignments

    change_table :item_assignments, bulk: true do |t|
      t.datetime :start_time
      t.datetime :finish_time
    end

    ItemAssignment.all.each do |assigment|
      assigment.update(start_time: (Demand.find(assigment.demand_id).commitment_date || Demand.find(assigment.demand_id).created_date), finish_time: Demand.find(assigment.demand_id).end_date)
      assigment.destroy unless assigment.valid?
    end

    change_column_null :item_assignments, :start_time, false

    add_index :item_assignments, %i[demand_id team_member_id start_time], unique: true, name: 'demand_member_start_time_unique'
  end
end
