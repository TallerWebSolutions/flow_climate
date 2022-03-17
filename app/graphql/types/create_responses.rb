# frozen_string_literal: true

module Types
  class CreateResponses < Types::BaseEnum
    value 'SUCCESS', 'answered when the creation was successful.'
    value 'FAIL', 'answered when the creation was not successful.'
  end
end
