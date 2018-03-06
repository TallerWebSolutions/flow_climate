# frozen_string_literal: true

class AddActiveToPipefyConfig < ActiveRecord::Migration[5.1]
  def change
    add_column :pipefy_configs, :active, :boolean, default: true
  end
end
