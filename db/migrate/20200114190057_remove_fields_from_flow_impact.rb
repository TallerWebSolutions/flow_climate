# frozen_string_literal: true

class RemoveFieldsFromFlowImpact < ActiveRecord::Migration[6.0]
  def up
    change_table :flow_impacts, bulk: true do |t|
      t.remove :end_date
      t.rename :start_date, :impact_date

      t.integer :impact_size, null: false, index: true, default: 0
      t.integer :user_id, index: true
    end

    add_foreign_key :flow_impacts, :users, column: :user_id
  end

  def down
    change_table :flow_impacts, bulk: true do |t|
      t.datetime :end_date
      t.rename :impact_date, :start_date

      t.remove :impact_size
      t.remove :user_id
    end
  end
end
