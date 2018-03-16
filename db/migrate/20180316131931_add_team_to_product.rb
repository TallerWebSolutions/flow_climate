# frozen_string_literal: true

class AddTeamToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :team_id, :integer, index: true
    add_foreign_key :products, :teams, column: :team_id
  end
end
