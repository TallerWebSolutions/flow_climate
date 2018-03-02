# frozen_string_literal: true

class AddAssigneesCountToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :assignees_count, :integer
    Demand.all.each { |demand| demand.update(assignees_count: 1) }
    change_column_null :demands, :assignees_count, false
  end
end
