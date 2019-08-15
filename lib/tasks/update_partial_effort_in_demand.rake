# frozen_string_literal: true

desc 'Update partial efforts'

namespace :demands do
  task update_partial_effort: :environment do
    Demand.in_wip.each(&:update_effort!)
  end
end
