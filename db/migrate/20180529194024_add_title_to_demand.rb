# frozen_string_literal: true

class AddTitleToDemand < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :demand_title, :string
  end
end
