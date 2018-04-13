# frozen_string_literal: true

class AddLeadtimeToDemand < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :leadtime, :decimal
  end
end
