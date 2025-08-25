# Create user
email = 'mauricio@taller.net.br'

user_attributes = {
  first_name: 'Mauricio',
  last_name: 'Cassiano',
  email_address: email,
  password: 'Taller.123',
  password_confirmation: 'Taller.123'
}

new_user = User.new(user_attributes)

if new_user.save
  puts "User '#{new_user.email_address}' created successfully!"
else
  puts "Failed to create user. Errors: #{new_user.errors.full_messages.join(', ')}"
end

# Add plan to User

u = User.find_by(email_address: email)
UserPlan.create(user: u, plan: Plan.find(3), start_at: Time.zone.now, finish_at: 1.year.from_now, active: true, paid: true)
u.user_plans.last.update(finish_at: 1.year.from_now)

# Associate a user with a company

user_to_associate = User.find_by(email_address: email)
company = Company.find(1)

if user_to_associate.present? && company.present?
  company.add_user(user_to_associate)
  puts "Successfully associated '#{user_to_associate.full_name}' with '#{company.name}'."
elsif user_to_associate.blank?
  puts "Error: Could not find a user with the email '#{email}'."
end
