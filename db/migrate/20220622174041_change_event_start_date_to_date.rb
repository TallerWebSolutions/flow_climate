# frozen_string_literal: true

class ChangeEventStartDateToDate < ActiveRecord::Migration[7.0]
  def up
    change_column :flow_events, :event_date, :date
  end

  def down
    change_column :flow_events, :event_date, :datetime
  end
end
