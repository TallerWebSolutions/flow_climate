# frozen_string_literal: true

class CreateCompanyWorkingHoursConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :company_working_hours_configs do |t|
      t.references :company, null: false, foreign_key: true
      t.decimal :hours_per_day, precision: 4, scale: 1, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.timestamps
    end

    add_index :company_working_hours_configs, %i[company_id start_date end_date], name: 'idx_company_working_hours_dates'
  end
end
