# frozen_string_literal: true

class AddClassOfServiceToDemand < ActiveRecord::Migration[5.1]
  def up
    add_column :demands, :class_of_service, :integer, default: 0, null: false, index: true
    Demand.where(demand_type: nil).each { |demand| demand.update(demand_type: 0) }
    change_column_null :demands, :demand_type, false
  end

  def down
    remove_column :demands, :class_of_service, :integer, default: 0, null: false, index: true
    change_column_null :demands, :demand_type, true
  end
end
