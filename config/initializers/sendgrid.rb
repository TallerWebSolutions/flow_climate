# frozen_string_literal: true

ActionMailer::Base.smtp_settings = {
  user_name: Figaro.env.sendgrid_username,
  password: Figaro.env.password,
  domain: 'taller.net.br',
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}
