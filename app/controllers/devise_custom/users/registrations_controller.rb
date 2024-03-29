# frozen_string_literal: true

module DeviseCustom
  module Users
    class RegistrationsController < Devise::RegistrationsController
      private

      def sign_up_params
        params.require(:user).permit(:first_name, :last_name, :email, :language, :password, :password_confirmation)
      end
    end
  end
end
