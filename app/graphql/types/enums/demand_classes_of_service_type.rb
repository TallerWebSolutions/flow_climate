# frozen_string_literal: true

module Types
  module Enums
    class DemandClassesOfServiceType < Types::BaseEnum
      value 'ALL', 'Expedite'
      value 'EXPEDITE', 'Expedite'
      value 'STANDARD', 'Standard'
      value 'FIXED_DATE', 'Fixed Date'
      value 'INTANGIBLE', 'Intangible'
    end
  end
end
