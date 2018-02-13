# frozen_string_literal: true

class AddCreatedDateToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :created_date, :datetime

    Demand.all.each { |demand| demand.update(created_date: demand.commitment_date || demand.created_at) }

    change_column_null :demands, :created_date, false
  end
end
