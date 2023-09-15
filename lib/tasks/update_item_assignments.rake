# frozen_string_literal: true

desc 'Update item_assignments'

namespace :item_assignments do
  task save_to_update_effort: :environment do
    Membership.find_each do |member|
      member.item_assignments.map(&:save)
    end
  end
end
