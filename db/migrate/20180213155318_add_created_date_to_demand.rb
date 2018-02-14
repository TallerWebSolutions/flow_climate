# frozen_string_literal: true

class AddCreatedDateToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :created_date, :datetime, null: false
  end
end
