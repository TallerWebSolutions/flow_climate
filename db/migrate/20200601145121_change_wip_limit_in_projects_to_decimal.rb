# frozen_string_literal: true

##
# Wip limit should be decimal to improve monte carlo simulations.
class ChangeWipLimitInProjectsToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :projects, :max_work_in_progress, :decimal, default: 1
  end

  def down
    change_column :projects, :max_work_in_progress, :integer
  end
end
