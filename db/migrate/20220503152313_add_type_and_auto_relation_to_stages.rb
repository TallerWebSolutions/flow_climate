# frozen_string_literal: true

class AddTypeAndAutoRelationToStages < ActiveRecord::Migration[7.0]
  def change
    add_column :stages, :stage_level, :integer, null: false, default: 0
    add_index :stages, :stage_level
  end
end
