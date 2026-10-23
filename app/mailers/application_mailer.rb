class ApplicationMailer < ActionMailer::Base
  self.delivery_job = MailDeliveryJob
  default from: ENV.fetch("MAIL_FROM", "MSIA <bonjour@msia.test>")
  layout "mailer"
end
