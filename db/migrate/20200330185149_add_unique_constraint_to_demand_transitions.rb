# frozen_string_literal: true

class AddUniqueConstraintToDemandTransitions < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      delete
      from
	      demand_transitions dt
		      using demand_transitions dt_in
      where
	      dt_in.id > dt.id
	      and dt_in.demand_id = dt.demand_id
	      and dt_in.stage_id = dt.stage_id
	      and dt_in.last_time_in = dt.last_time_in;
    SQL

    add_index :demand_transitions, %i[demand_id stage_id last_time_in], unique: true, name: 'idx_transitions_unique'
  end

  def down
    remove_index :demand_transitions, %i[demand_id stage_id last_time_in]
  end
end
