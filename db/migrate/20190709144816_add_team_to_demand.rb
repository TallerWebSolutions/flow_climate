# frozen_string_literal: true

class AddTeamToDemand < ActiveRecord::Migration[5.2]
  def up
    add_column :demands, :team_id, :integer
    add_index :demands, :team_id
    add_foreign_key :demands, :teams, column: :team_id
    execute('UPDATE demands d SET team_id = (SELECT team_id FROM projects p WHERE d.project_id = p.id);')
    change_column_null :demands, :team_id, false

    change_column_null :projects, :team_id, false
  end

  def down
    remove_column :demands, :team_id
  end
end
