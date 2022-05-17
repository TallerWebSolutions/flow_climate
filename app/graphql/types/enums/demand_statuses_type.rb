# frozen_string_literal: true

module Types
  module Enums
    class DemandStatusesType < Types::BaseEnum
      value 'ALL', 'all demands'
      value 'FINISHED', 'demands finished'
    end
  end
end
