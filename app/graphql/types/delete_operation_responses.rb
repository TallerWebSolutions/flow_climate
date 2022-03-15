# frozen_string_literal: true

module Types
  class DeleteOperationResponses < Types::BaseEnum
    value 'SUCCESS', 'the object was deleted'
    value 'FAIL', 'the server encountered problems to delete the object'
  end
end
