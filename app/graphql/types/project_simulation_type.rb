# frozen_string_literal: true

module Types
  class ProjectSimulationType < Types::BaseObject
    field :id, ID, null: false
    field :weekly_throughputs, [Integer], null: false
    field :max_work_in_progress, Float, null: false
  end
end
