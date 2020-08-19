# frozen_string_literal: true

desc 'Update partial efforts'

namespace :demands do
  task update_partial_effort: :environment do
    Demand.in_wip.each { |demand| demand.update_effort(false) }
  end
end
