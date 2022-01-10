# frozen_string_literal: true

module Types
  class BackgroundQueueResponses < Types::BaseEnum
    value 'SUCCESS', 'answered when the job was put in the queue'
    value 'FAIL', 'answered when failed to put the job in the queue'
  end
end
