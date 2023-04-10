# frozen_string_literal: true

class AddDownstreamBooleanToDemands < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :downstream, :boolean, default: true, null: false
  end
end
