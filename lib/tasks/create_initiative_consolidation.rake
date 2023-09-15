# frozen_string_literal: true

namespace :initiatives do
  task create_today_initiative_consolidation: :environment do
    Initiative.find_each do |initiative|
      Consolidations::InitiativeConsolidationJob.perform_later(initiative)
    end
  end
end
