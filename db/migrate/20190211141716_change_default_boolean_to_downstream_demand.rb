# frozen_string_literal: true

class ChangeDefaultBooleanToDownstreamDemand < ActiveRecord::Migration[5.2]
  def change
    change_column_default :demands, :downstream, from: true, to: false
  end
end
