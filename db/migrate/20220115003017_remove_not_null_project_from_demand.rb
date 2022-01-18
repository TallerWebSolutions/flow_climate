# frozen_string_literal: true

class RemoveNotNullProjectFromDemand < ActiveRecord::Migration[6.1]
  def change
    change_column_null :demands, :project_id, true
  end
end
