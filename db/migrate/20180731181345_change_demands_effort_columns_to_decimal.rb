# frozen_string_literal: true

class ChangeDemandsEffortColumnsToDecimal < ActiveRecord::Migration[5.2]
  def up
    change_table :project_results, bulk: true do |t|
      t.change :qty_hours_downstream, :decimal
      t.change :qty_hours_upstream, :decimal
    end
  end

  def down
    change_table :project_results, bulk: true do |t|
      t.change :qty_hours_downstream, :integer
      t.change :qty_hours_upstream, :integer
    end
  end
end
