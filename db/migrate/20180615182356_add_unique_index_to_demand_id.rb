# frozen_string_literal: true

class AddUniqueIndexToDemandId < ActiveRecord::Migration[5.2]
  def change
    add_index :demands, %i[demand_id project_id], unique: true
  end
end
