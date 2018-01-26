# frozen_string_literal: true

class AddDemandsIdsToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :demands_ids, :string
  end
end
