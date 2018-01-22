# frozen_string_literal: true

class AddMonteCarloDateToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :monte_carlo_date, :date
  end
end
