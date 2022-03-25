# frozen_string_literal: true

module Types
  module Charts
    class ChartsPeriodsType < Types::BaseEnum
      value 'DAILY', 'the charts data will be using the DAILY interval'
      value 'WEEKLY', 'the charts data will be using the WEEKLY interval'
      value 'MONTHLY', 'the charts data will be using the MONTHLY interval'
    end
  end
end
