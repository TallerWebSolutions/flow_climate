# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@taller.net.br'

  layout 'mailer'
end
