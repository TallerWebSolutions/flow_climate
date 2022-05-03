# frozen_string_literal: true

namespace :data do
  task transition_time_values: :environment do
    DemandTransition.all.map(&:save)
  end
end
