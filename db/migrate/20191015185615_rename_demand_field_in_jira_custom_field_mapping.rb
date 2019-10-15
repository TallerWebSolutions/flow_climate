# frozen_string_literal: true

class RenameDemandFieldInJiraCustomFieldMapping < ActiveRecord::Migration[6.0]
  def change
    rename_column :jira_custom_field_mappings, :demand_field, :custom_field_type

    change_table :demands, bulk: true do |t|
      t.rename :url, :external_url
      t.rename :demand_id, :external_id
    end
  end
end
