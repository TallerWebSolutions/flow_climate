# frozen_string_literal: true

module Types
  module Enums
    class WorkItemLevel < Types::BaseEnum
      value 'DEMAND', 'basic work item unit'
      value 'TASK', 'breakdown of a demand'
    end
  end
end
