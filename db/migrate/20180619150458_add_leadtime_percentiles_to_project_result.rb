# frozen_string_literal: true

class AddLeadtimePercentilesToProjectResult < ActiveRecord::Migration[5.2]
  def up
    change_table :project_results, bulk: true do |t|
      t.rename :leadtime, :leadtime_95_confidence
      t.decimal :leadtime_80_confidence
      t.decimal :leadtime_60_confidence
      t.decimal :leadtime_average

      t.change :leadtime_95_confidence, :decimal, null: true
    end
  end

  def down
    change_table :project_results, bulk: true do |t|
      t.rename :leadtime_95_confidence, :leadtime
      t.remove :leadtime_80_confidence
      t.remove :leadtime_60_confidence
      t.remove :leadtime_average
    end
  end
end
