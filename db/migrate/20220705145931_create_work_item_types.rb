# frozen_string_literal: true

class CreateWorkItemTypes < ActiveRecord::Migration[7.0]
  def up
    create_table :work_item_types do |t|
      t.integer :company_id, index: true, null: false
      t.string :name, null: false
      t.integer :item_level, index: true, null: false, default: 0
      t.boolean :quality_indicator_type, index: true, null: false, default: false

      t.timestamps
    end

    add_foreign_key :work_item_types, :companies, column: :company_id

    add_column :demands, :work_item_type_id, :integer
    add_index :demands, :work_item_type_id
    add_foreign_key :demands, :work_item_types, column: :work_item_type_id

    add_column :tasks, :work_item_type_id, :integer
    add_index :tasks, :work_item_type_id
    add_foreign_key :tasks, :work_item_types, column: :work_item_type_id

    # Demand types
    execute('insert into work_item_types (name, company_id, item_level, created_at, updated_at) select \'Feature\', c.id, 0, current_timestamp, current_timestamp from companies c')
    execute('insert into work_item_types (name, company_id, item_level, quality_indicator_type, created_at, updated_at) select \'Bug\', c.id, 0, true, current_timestamp, current_timestamp from companies c')
    execute('insert into work_item_types (name, company_id, item_level, created_at, updated_at) select \'Chore\', c.id, 0, current_timestamp, current_timestamp from companies c')

    # Task type
    execute('insert into work_item_types (name, company_id, item_level, created_at, updated_at) select \'PoS Material\', c.id, 1, current_timestamp, current_timestamp from companies c where c.company_type = 1')

    # update all demands types
    execute('update demands as d set work_item_type_id = (select id from work_item_types wit where wit.company_id = d.company_id and wit.name = \'Feature\') where d.demand_type = 0')
    execute('update demands as d set work_item_type_id = (select id from work_item_types wit where wit.company_id = d.company_id and wit.name = \'Bug\') where d.demand_type = 1')
    execute('update demands as d set work_item_type_id = (select id from work_item_types wit where wit.company_id = d.company_id and wit.name = \'Chore\') where work_item_type_id is null')

    # update all tasks type
    execute('update tasks as t set work_item_type_id = (select id from work_item_types wit where wit.name = \'PoS Material\' and d.company_id = wit.company_id) from demands d where t.demand_id = d.id and t.work_item_type_id is null')

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
