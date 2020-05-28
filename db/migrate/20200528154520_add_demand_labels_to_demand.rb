# frozen_string_literal: true

class AddDemandLabelsToDemand < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :demand_tags, :string, array: true, default: []
  end
end
