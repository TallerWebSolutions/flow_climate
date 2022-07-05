# frozen_string_literal: true

class CreateWorkItemTypes < ActiveRecord::Migration[7.0]
  def up
    create_table :work_item_types do |t|
      t.integer :company_id, index: true, null: false
      t.string :name, null: false
      t.integer :item_level, index: true, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :work_item_types, :companies, column: :company_id

    add_column :demands, :work_item_type_id, :integer
    add_index :demands, :work_item_type_id
    add_foreign_key :demands, :work_item_types, column: :work_item_type_id

    add_column :tasks, :work_item_type_id, :integer
    add_index :tasks, :work_item_type_id
    add_foreign_key :tasks, :work_item_types, column: :work_item_type_id

    Company.all.each do |company|
      feature = WorkItemType.create(name: 'Feature', company_id: company.id, item_level: 0)
      bug = WorkItemType.create(name: 'Bug', company_id: company.id, item_level: 0)
      chore = WorkItemType.create(name: 'Chore', company_id: company.id, item_level: 0)

      company.demands.each do |demand|
        case demand.demand_type_before_type_cast
        when 0
          demand.update(work_item_type_id: feature.id)
        when 1
          demand.update(work_item_type_id: bug.id)
        else
          demand.update(work_item_type_id: chore.id)
        end
      end

      next unless company.marketing?

      pos_material = WorkItemType.create(name: 'PoS Material', company_id: company.id, item_level: 1)

      company.tasks.each do |task|
        task.update(work_item_type_id: pos_material.id)
      end
    end

    change_column_null :demands, :work_item_type_id, false
    remove_column :demands, :demand_type

    change_column_null :tasks, :work_item_type_id, false
  end

  def down
    add_column :demands, :demand_type, :integer
    remove_foreign_key :tasks, :work_item_types
    remove_column :demands, :work_item_type_id
    remove_column :tasks, :work_item_type_id
    drop_table :work_item_types
  end
end
