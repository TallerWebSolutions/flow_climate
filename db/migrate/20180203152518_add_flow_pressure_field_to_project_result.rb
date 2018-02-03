# frozen_string_literal: true

class AddFlowPressureFieldToProjectResult < ActiveRecord::Migration[5.1]
  def up
    add_column :project_results, :flow_pressure, :decimal
    add_column :project_results, :remaining_days, :integer

    # Add value to null columns
    Project.all.each do |project|
      next if project.project_results.blank?
      min_result_date = project.project_results.minimum(:result_date)
      max_result_date = project.project_results.maximum(:result_date)

      if project.start_date > min_result_date
        project.update(start_date: min_result_date)
      end

      if project.end_date < max_result_date
        project.update(end_date: max_result_date)
      end

      array_of_weeks = []
      min_date = project.start_date
      max_date = project.end_date

      while min_date <= max_date
        array_of_weeks << [min_date.cweek, min_date.cwyear]
        min_date += 7.days
      end
      array_of_weeks.each do |week_year|
        results_per_week = project.project_results.for_week(week_year[0], week_year[1])
        results_per_week.each do |result|
          if result.project.remaining_days != 0
            result.update(flow_pressure: result.known_scope.to_f / result.project.remaining_days.to_f)
            result.update(remaining_days: result.project.remaining_days(result.result_date))
          else
            result.update(flow_pressure: 0)
            result.update(remaining_days: 0)
          end
        end
      end
    end

    change_column_null :project_results, :flow_pressure, false
    change_column_null :project_results, :remaining_days, false
  end

  def down
    remove_column :project_results, :flow_pressure
    remove_column :project_results, :remaining_days
  end
end
