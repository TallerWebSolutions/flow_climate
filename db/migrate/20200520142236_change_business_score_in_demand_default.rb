# frozen_string_literal: true

class ChangeBusinessScoreInDemandDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :demands, :business_score, from: nil, to: 0

    rename_column :demands, :business_score, :demand_score

    # rubocop:disable Rails/SkipsModelValidations
    Demand.where(demand_score: nil).update_all(demand_score: 0)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
