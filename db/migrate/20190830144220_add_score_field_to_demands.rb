# frozen_string_literal: true

class AddScoreFieldToDemands < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :business_score, :decimal
  end
end
