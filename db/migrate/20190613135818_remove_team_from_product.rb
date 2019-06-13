# frozen_string_literal: true

class RemoveTeamFromProduct < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :team_id, :integer
  end
end
