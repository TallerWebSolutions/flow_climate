# frozen_string_literal: true

Fabricator(:pipefy_config, from: 'Pipefy::PipefyConfig') do
  company
  team
  project
  pipe_id '33445'
end
