# frozen_string_literal: true

class AddConsumedHoursToContract < ActiveRecord::Migration[7.1]
  def change
    change_table :contract_consolidations, bulk: true do |t|
      t.float :consumed_hours, default: 0
    end
  end
end
