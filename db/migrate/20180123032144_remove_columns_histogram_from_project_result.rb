# frozen_string_literal: true

class RemoveColumnsHistogramFromProjectResult < ActiveRecord::Migration[5.1]
  def change
    remove_column :project_results, :histogram_first_mode, :decimal
    remove_column :project_results, :histogram_second_mode, :decimal
  end
end
