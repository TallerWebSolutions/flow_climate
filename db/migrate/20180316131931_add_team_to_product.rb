# frozen_string_literal: true

class AddTeamToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :team_id, :integer
    add_index :products, :team_id
    add_foreign_key :products, :teams, column: :team_id
  end
end
