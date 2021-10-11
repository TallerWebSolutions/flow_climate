# frozen_string_literal: true

class AddLockToDemandEffort < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_efforts, :lock_version, :integer
  end
end
