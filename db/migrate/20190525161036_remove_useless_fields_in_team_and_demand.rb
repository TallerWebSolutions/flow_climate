# frozen_string_literal: true

class RemoveUselessFieldsInTeamAndDemand < ActiveRecord::Migration[5.2]
  def up
    change_table :demands, bulk: true do |t|
      t.remove :downstream
    end

    change_table :project_jira_configs, bulk: true do |t|
      t.remove :team_id
      t.remove :jira_account_domain
      t.remove :active
    end
  end

  def down
    change_table :demands, bulk: true do |t|
      t.boolean :downstream, null: false, default: true
    end

    change_table :project_jira_configs, bulk: true do |t|
      t.integer :team_id, index: true
      t.string :jira_account_domain
      t.boolean :active, null: false, default: true
    end

    add_foreign_key :project_jira_configs, :teams, column: :team_id
  end
end
