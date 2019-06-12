# frozen_string_literal: true

desc 'Start of plans'

namespace :demands do
  task update_partial_effort: :environment do
    Demand.in_wip.each(&:update_effort!)
  end
end
