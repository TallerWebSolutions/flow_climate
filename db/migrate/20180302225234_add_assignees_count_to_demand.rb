# frozen_string_literal: true

class AddAssigneesCountToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :assignees_count, :integer, null: false
  end
end
