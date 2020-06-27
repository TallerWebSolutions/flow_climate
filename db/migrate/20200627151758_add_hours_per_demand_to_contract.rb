# frozen_string_literal: true

class AddHoursPerDemandToContract < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :hours_per_demand, :integer, default: 1, null: false
  end
end
