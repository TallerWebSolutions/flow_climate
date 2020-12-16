# frozen_string_literal: true

class CreateClassOfServiceChangeHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :class_of_service_change_histories do |t|
      t.integer :demand_id, null: false, index: true
      t.datetime :change_date, null: false

      # we are allowing null here to map the first change in CoS
      t.integer :from_class_of_service

      t.integer :to_class_of_service, null: false

      t.timestamps
    end

    add_foreign_key :class_of_service_change_histories, :demands, column: :demand_id
    add_index :class_of_service_change_histories, %i[demand_id change_date], unique: true, name: :cos_history_unique
  end
end
