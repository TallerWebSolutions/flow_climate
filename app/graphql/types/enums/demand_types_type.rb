# frozen_string_literal: true

module Types
  module Enums
    class DemandTypesType < Types::BaseEnum
      value 'ALL', 'All demands'
      value 'BUG', 'Demands bug'
      value 'CHORE', 'Demands chore'
    end
  end
end
