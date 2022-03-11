# frozen_string_literal: true

module DeviseCustom
  module DeviseCustomers
    class RegistrationsController < Devise::RegistrationsController
      def create
        super

        check_invites
      end

      private

      def sign_up_params
        params.require(:devise_customer).permit(:first_name, :last_name, :email, :language, :password, :password_confirmation)
      end

      def check_invites
        invites = UserInvite.where(invite_email: resource.email, invite_status: :pending)
        invites.each do |user_invite|
          next unless user_invite.customer?

          customer = Customer.find(user_invite.invite_object_id)
          customer.add_user(resource)
          user_invite.accepted!
        end
      end
    end
  end
end
