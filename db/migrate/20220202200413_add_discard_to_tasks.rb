# frozen_string_literal: true

class AddDiscardToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :discarded_at, :datetime
    add_index :tasks, :discarded_at
  end
end
