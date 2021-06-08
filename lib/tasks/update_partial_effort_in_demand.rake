# frozen_string_literal: true

desc 'Update partial efforts'

namespace :demands do
  task update_partial_effort: :environment do
    Demand.in_wip(Time.zone.now).each { |demand| DemandEffortService.instance.build_efforts_to_demand(demand) }
  end
end
