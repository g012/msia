class WaitlistMailer < ApplicationMailer
  def welcome(signup)
    @signup = signup
    return if @signup.unsubscribed_at?
    I18n.with_locale(signup.locale) do
      headers["List-Unsubscribe"] = "<#{unsubscribe_url(locale: signup.locale, token: signup.unsubscribe_token)}>"
      mail(to: signup.email, subject: I18n.t("mail.subject"))
    end
  end
end
