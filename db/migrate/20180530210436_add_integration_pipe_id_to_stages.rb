# frozen_string_literal: true

class AddIntegrationPipeIdToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :integration_pipe_id, :string
  end
end
