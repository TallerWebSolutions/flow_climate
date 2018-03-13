# frozen_string_literal: true

class ChangeDemandsCreatedDateNull < ActiveRecord::Migration[5.1]
  def change
    Demand.where(created_date: nil).each { |demand| demand.update(created_date: demand.created_at) }
    change_column_null :demands, :created_date, false
  end
end
