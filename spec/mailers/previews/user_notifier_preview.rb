# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
class UserNotifierMailerPreview < ActionMailer::Preview
  def sync_finished
    user_name = 'Foo Bar'
    user_email = 'bla@xpto.com'
    sync_title = 'demanda'
    object_title = 'XPTO-BLA'
    sync_started_at = 30.minutes.ago
    sync_finished_at = 5.minutes.ago
    object_url = 'http://foo.com.br'

    UserNotifierMailer.sync_finished(user_email, user_name, sync_title, object_title, sync_started_at, sync_finished_at, object_url)
  end
end
