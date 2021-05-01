# frozen_string_literal: true

class RemoveDemandDataProcessment < ActiveRecord::Migration[6.1]
  def change
    drop_table :demand_data_processments do
      t.integer :user_id, null: false, index: true
      t.string :project_key, null: false
      t.text :downloaded_content, null: false
      t.timestamps
    end
  end
end
