# frozen_string_literal: true

class AddMaxWorkInProgreeToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :max_work_in_progress, :integer, default: 0, null: false
    add_column :teams, :max_work_in_progress, :integer, default: 0, null: false
  end
end
