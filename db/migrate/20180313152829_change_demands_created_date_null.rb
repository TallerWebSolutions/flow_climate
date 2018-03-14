# frozen_string_literal: true

class ChangeDemandsCreatedDateNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :demands, :created_date, false
  end
end
