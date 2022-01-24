# frozen_string_literal: true

module Mutations
  class SendAuthTokenMutation < Mutations::BaseMutation
    argument :company_id, Int, required: true

    field :status_message, Types::BackgroundQueueResponses, null: false

    def resolve(company_id:)
      company = Company.find(company_id)

      if current_user.present?
        UserNotifierMailer.send_auth_token(company, current_user.email).deliver_now
        { status_message: "SUCCESS" }
      else
        { status_message: "FAIL" }
      end
    end
  end
end
