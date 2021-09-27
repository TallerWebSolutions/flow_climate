# frozen_string_literal: true

class AddLockToDemandBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :demand_blocks, :lock_version, :integer
  end
end
