# frozen_string_literal: true

class AddClassOfServiceToDemand < ActiveRecord::Migration[5.1]
  def up
    change_table :demands, bulk: true do |t|
      t.integer :class_of_service, default: 0, null: false, index: true
    end

    change_column_null :demands, :demand_type, false
  end

  def down
    change_table :demands, bulk: true do |t|
      t.remove :class_of_service
    end
    change_column_null :demands, :demand_type, true
  end
end
