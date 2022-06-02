# frozen_string_literal: true

module Types
  module Enums
    class DemandStatusesType < Types::BaseEnum
      value 'ALL_DEMANDS', 'All Activities'
      value 'NOT_COMMITTED', 'Not Committed'
      value 'WORK_IN_PROGRESS', 'Work in Progress'
      value 'DELIVERED_DEMANDS', 'Delivered'
      value 'NOT_STARTED', 'Not Started'
      value 'DISCARDED_DEMANDS', 'Discarded'
      value 'NOT_DISCARDED_DEMANDS', 'Not Discarded'
    end
  end
end
