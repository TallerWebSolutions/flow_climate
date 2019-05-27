# frozen_string_literal: true

class CreateDemandComments < ActiveRecord::Migration[5.2]
  def change
    create_table :demand_comments do |t|
      t.integer :demand_id, null: false, index: true
      t.datetime :comment_date, null: false
      t.string :comment_text, null: false

      t.timestamps
    end

    add_foreign_key :demand_comments, :demands, column: :demand_id
  end
end
