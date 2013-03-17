class Mailer < ActionMailer::Base
  default from: "no-reply@5likes.ru"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.mailer.send_feedback.subject
  #
  def send_feedback(email,name,text)
    @email = email
    @name = name
    @text = text
    mail to: "grandison@mail.ru", :subject => "Feedback from email: #{email}, name: #{name}"
  end
end
