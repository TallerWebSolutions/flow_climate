# frozen_string_literal: true

module Types
  class CreateResponses < Types::BaseEnum
    value 'SUCCESS', 'answered when the creation was successful.'
    value 'FAIL', 'answered when the creation was not successful.'
    value 'NOT_FOUND', 'answered when relationship arguments are invalid.'
  end
end
