# frozen_string_literal: true

class AddControlColumnsToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :demand_type, :integer, index: true
    add_column :demands, :demand_url, :string
    add_column :demands, :commitment_date, :datetime
    add_column :demands, :end_date, :datetime
  end
end
