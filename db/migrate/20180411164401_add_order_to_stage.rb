# frozen_string_literal: true

class AddOrderToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :order, :integer, default: 0, null: false
  end
end
