# frozen_string_literal: true

class AddEffortShareInMonth < ActiveRecord::Migration[5.2]
  def change
    add_column :project_results, :effort_share_in_month, :decimal
  end
end
