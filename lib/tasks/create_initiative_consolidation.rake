# frozen_string_literal: true

namespace :initiatives do
  task create_today_iniciative_consolidation: :environment do
    Initiative.all.each do |initiative|
      Consolidations::InitiativeConsolidationJob.perform_later(initiative)
    end
  end
end
