# frozen_string_literal: true

namespace :maintenance do
  task change_wakanda_transitions: :environment do
    old_stages_ids = [2, 326, 1, 3, 4, 5, 6, 7, 8, 9]
    new_stages_ids = [40, 18, 19, 20, 21, 22, 23, 24, 25, 26]

    old_stages_ids.each_with_index do |old_stage_id, index|
      old_stage = Stage.find(old_stage_id)
      new_stage = Stage.find(new_stages_ids[index])
      Rails.logger.info("Migrating #{old_stage.demand_transitions.count} transitions of #{old_stage.name}")
      old_stage.demand_transitions.with_discarded.each do |transition|
        if new_stage.demand_transitions.with_discarded.where(last_time_in: transition.last_time_in, demand: transition.demand).count.positive?
          transition.destroy!
        else
          transition.update!(stage: new_stage)
        end

      end
      old_stage.demand_blocks.with_discarded.each { |block| block.update!(stage: new_stage) }

      StageProjectConfig.where(stage: old_stage).each { |config| config.update!(stage: new_stage) }
      old_stage.destroy!
    end

    #
    # Backlog 2 -> 40
    # In Design 326 -> 18
    # OI 1 -> 19
    # R4Dev 3 -> 20
    # Developing 4 -> 21
    # Ready to HMG 5 -> 22
    # Homologating 6 -> 23
    # R4Deploy 7 -> 24
    # Live 8 -> 25
    # Arquivado 9 -> 26
  end
end
