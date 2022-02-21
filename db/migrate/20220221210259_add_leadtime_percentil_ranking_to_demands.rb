# frozen_string_literal: true

class AddLeadtimePercentilRankingToDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :demands, :lead_time_percentile_project_ranking, :float
  end
end
