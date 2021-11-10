# frozen_string_literal: true

class RenameFlowImpactToFlowEvent < ActiveRecord::Migration[6.1]
  def change
    rename_table :flow_impacts, :flow_events

    add_column :flow_events, :event_end_date, :date, null: true

    rename_column :flow_events, :impact_date, :event_date
    rename_column :flow_events, :impact_description, :event_description
    rename_column :flow_events, :impact_size, :event_size
    rename_column :flow_events, :impact_type, :event_type

    change_table :flow_events, bulk: true do |t|
      t.integer :company_id
      t.integer :team_id
    end

    remove_column :flow_events, :demand_id, :integer

    change_column_null :flow_events, :project_id, true

    FlowEvent.all.each { |event| event.update(company_id: event.project.company.id) }

    change_column_null :flow_events, :company_id, false
  end
end
