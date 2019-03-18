class ChangeDefaultForStageEffort < ActiveRecord::Migration[5.2]
  def up
    change_table :stage_project_configs, bulk: true do |t|
      t.change_default :management_percentage, from: nil, to: 0
      t.change_default :pairing_percentage, from: nil, to: 0
      t.change_default :stage_percentage, from: nil, to: 0
    end

    execute('UPDATE stage_project_configs SET management_percentage = 0 WHERE management_percentage IS NULL')
    execute('UPDATE stage_project_configs SET pairing_percentage = 0 WHERE pairing_percentage IS NULL')
    execute('UPDATE stage_project_configs SET stage_percentage = 0 WHERE stage_percentage IS NULL')
  end

  def down
    change_table :stage_project_configs, bulk: true do |t|
      t.change_default :management_percentage, from: 0, to: nil
      t.change_default :pairing_percentage, from: 0, to: nil
      t.change_default :stage_percentage, from: 0, to: nil
    end
  end
end
