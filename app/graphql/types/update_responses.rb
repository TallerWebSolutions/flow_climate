# frozen_string_literal: true

module Types
  class UpdateResponses < Types::BaseEnum
    value 'SUCCESS', 'answered when the update was successful.'
    value 'FAIL', 'answered when the update was not successful.'
    value 'NOT_FOUND', 'answered when the object was not found.'
  end
end
