# frozen_string_literal: true

class AddRoleEffortFieldsToConsolidations < ActiveRecord::Migration[6.1]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.decimal :project_throughput_hours_development, default: 0, null: false
      t.decimal :project_throughput_hours_design, default: 0, null: false
      t.decimal :project_throughput_hours_management, default: 0, null: false

      t.decimal :project_throughput_hours_development_in_month, default: 0, null: false
      t.decimal :project_throughput_hours_design_in_month, default: 0, null: false
      t.decimal :project_throughput_hours_management_in_month, default: 0, null: false
    end

    change_table :customer_consolidations, bulk: true do |t|
      t.decimal :development_consumed_hours, default: 0, null: false
      t.decimal :design_consumed_hours, default: 0, null: false
      t.decimal :management_consumed_hours, default: 0, null: false

      t.decimal :development_consumed_hours_in_month, default: 0, null: false
      t.decimal :design_consumed_hours_in_month, default: 0, null: false
      t.decimal :management_consumed_hours_in_month, default: 0, null: false
    end

    change_table :contract_consolidations, bulk: true do |t|
      t.decimal :development_consumed_hours, default: 0, null: false
      t.decimal :design_consumed_hours, default: 0, null: false
      t.decimal :management_consumed_hours, default: 0, null: false

      t.decimal :development_consumed_hours_in_month, default: 0, null: false
      t.decimal :design_consumed_hours_in_month, default: 0, null: false
      t.decimal :management_consumed_hours_in_month, default: 0, null: false
    end

    change_table :team_consolidations, bulk: true do |t|
      t.decimal :development_consumed_hours, default: 0, null: false
      t.decimal :design_consumed_hours, default: 0, null: false
      t.decimal :management_consumed_hours, default: 0, null: false

      t.decimal :development_consumed_hours_in_month, default: 0, null: false
      t.decimal :design_consumed_hours_in_month, default: 0, null: false
      t.decimal :management_consumed_hours_in_month, default: 0, null: false
    end

    change_table :demands, bulk: true do |t|
      t.decimal :effort_development, default: 0, null: false
      t.decimal :effort_design, default: 0, null: false
      t.decimal :effort_management, default: 0, null: false

      t.remove :blocked_working_time_downstream
      t.remove :blocked_working_time_upstream
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove :project_throughput_hours_development
      t.remove :project_throughput_hours_design
      t.remove :project_throughput_hours_management

      t.remove :project_throughput_hours_development_in_month
      t.remove :project_throughput_hours_design_in_month
      t.remove :project_throughput_hours_management_in_month
    end

    change_table :customer_consolidations, bulk: true do |t|
      t.remove :development_consumed_hours
      t.remove :design_consumed_hours
      t.remove :management_consumed_hours

      t.remove :development_consumed_hours_in_month
      t.remove :design_consumed_hours_in_month
      t.remove :management_consumed_hours_in_month
    end

    change_table :contract_consolidations, bulk: true do |t|
      t.remove :development_consumed_hours
      t.remove :design_consumed_hours
      t.remove :management_consumed_hours

      t.remove :development_consumed_hours_in_month
      t.remove :design_consumed_hours_in_month
      t.remove :management_consumed_hours_in_month
    end

    change_table :team_consolidations, bulk: true do |t|
      t.remove :development_consumed_hours
      t.remove :design_consumed_hours
      t.remove :management_consumed_hours

      t.remove :development_consumed_hours_in_month
      t.remove :design_consumed_hours_in_month
      t.remove :management_consumed_hours_in_month
    end

    change_table :demands, bulk: true do |t|
      t.remove :effort_development
      t.remove :effort_design
      t.remove :effort_management

      t.decimal :blocked_working_time_downstream
      t.decimal :blocked_working_time_upstream
    end
  end
end
