# frozen_string_literal: true

class AddColumnAvailableHours < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :available_hours, :decimal

    ProjectResult.all.each { |result| result.update(available_hours: (result.team.current_outsourcing_monthly_available_hours.to_f / 4)) }

    change_column_null :project_results, :available_hours, false
  end
end
