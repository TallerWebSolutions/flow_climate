# frozen_string_literal: true

class AddStageIdToStages < ActiveRecord::Migration[7.0]
  def change
    add_column :stages, :parent_id, :integer, null: true
    add_index :stages, :parent_id

    add_foreign_key :stages, :stages, column: :parent_id
  end
end
