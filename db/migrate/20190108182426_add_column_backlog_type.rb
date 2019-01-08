# frozen_string_literal: true

class AddColumnBacklogType < ActiveRecord::Migration[5.2]
  def change
    change_table :demands, bulk: true do |t|
      t.integer :artifact_type, default: 0
      t.integer :parent_id, index: true
    end

    add_foreign_key :demands, :demands, column: :parent_id
  end
end
