# frozen_string_literal: true

desc 'Update partial efforts'

namespace :item_assignments do
  task save_to_update_effort: :environment do
    ItemAssignment.all.map(&:save)
  end
end
