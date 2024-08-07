# frozen_string_literal: true

class UserInviteService
  include Singleton

  def invite_customer(company, customer_id, invite_email, registration_url)
    customer = Customer.find(customer_id)
    devise_customer = DeviseCustomer.find_by(email: invite_email)
    if devise_customer.present?
      customer.add_user(devise_customer)
      message = I18n.t('customers.add_user_to_customer.success')
    else
      UserInvite.create(company: company, invite_email: invite_email, invite_object_id: customer.id, invite_type: :customer, invite_status: :pending)
      UserNotifierMailer.user_invite_to_customer(invite_email, customer.name, registration_url).deliver
      message = I18n.t('user_invites.create.success')
    end

    message
  end

  def remove_customer(customer, devise_customers_id)
    devise_customer = DeviseCustomer.find_by(id: devise_customers_id)
    user_invite = UserInvite.find_by(invite_email: devise_customer.email)
    user_invite.delete if user_invite.present?
    customer.remove_user(devise_customer)
    devise_customer.delete
    I18n.t('user_invites.delete.success')
  end
end
