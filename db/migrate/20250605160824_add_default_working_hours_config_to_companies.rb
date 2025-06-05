# frozen_string_literal: true

class AddDefaultWorkingHoursConfigToCompanies < ActiveRecord::Migration[7.0]
  def up
    Company.find_each do |company|
      CompanyWorkingHoursConfig.create!(
        company: company,
        hours_per_day: 6,
        start_date: Date.new(1980, 1, 1)
      )
    end
  end

  def down
    CompanyWorkingHoursConfig.where(start_date: Date.new(1980, 1, 1)).destroy_all
  end
end
