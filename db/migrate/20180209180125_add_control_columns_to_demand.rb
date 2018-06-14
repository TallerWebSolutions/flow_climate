# frozen_string_literal: true

class AddControlColumnsToDemand < ActiveRecord::Migration[5.1]
  def change
    change_table :demands, bulk: true do |t|
      t.integer :demand_type, index: true
      t.string :demand_url
      t.datetime :commitment_date
      t.datetime :end_date
    end
  end
end
