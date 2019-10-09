# frozen_string_literal: true

class RemoveArtifactTypeFromDemand < ActiveRecord::Migration[6.0]
  def up
    execute 'DROP VIEW demands_lists'

    change_table :demands, bulk: true do |t|
      t.remove :artifact_type
      t.integer :current_stage_id, index: true
    end

    add_foreign_key :demands, :stages, column: :current_stage_id
  end

  def down
    execute 'CREATE VIEW demands_lists AS SELECT id FROM demands'

    change_table :demands, bulk: true do |t|
      t.integer :artifact_type
      t.remove :current_stage_id
    end
  end
end
