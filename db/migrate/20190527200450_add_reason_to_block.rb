# frozen_string_literal: true

class AddReasonToBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_blocks, :block_reason, :string

    add_index :jira_accounts, :base_uri, unique: true
  end
end
