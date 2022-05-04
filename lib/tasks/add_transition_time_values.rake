# frozen_string_literal: true

namespace :data do
  task transition_time_values: :environment do
    execute('update demand_transitions set transition_time_in_sec = data_table.time_sum from (select id, extract(EPOCH from (transitions_inner.last_time_out - transitions_inner.last_time_in)) as time_sum from demand_transitions as transitions_inner where transitions_inner.last_time_out is not null) as data_table where demand_transitions.id = data_table.id;')
  end
end
