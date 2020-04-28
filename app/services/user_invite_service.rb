# frozen_string_literal: true

class UserInviteService
  include Singleton

  def invite_customer(company, customer_id, invite_email, registration_url)
    customer = Customer.find(customer_id)
    user = User.find_by(email: invite_email)
    if user.present?
      customer.add_user(user)
      message = I18n.t('customers.add_user_to_customer.success')
    else
      UserInvite.create(company: company, invite_email: invite_email, invite_object_id: customer.id, invite_type: :customer, invite_status: :pending)
      UserNotifierMailer.user_invite_to_customer(invite_email, customer.name, registration_url).deliver
      message = I18n.t('user_invites.create.success')
    end

    message
  end
end
