# frozen_string_literal: true

class RemoveColumnsHistogramFromProjectResult < ActiveRecord::Migration[5.1]
  def up
    change_table :project_results, bulk: true do |t|
      t.remove :histogram_first_mode
      t.remove :histogram_second_mode
    end
  end

  def down
    change_table :project_results, bulk: true do |t|
      t.decimal :histogram_first_mode
      t.decimal :histogram_second_mode
    end
  end
end
