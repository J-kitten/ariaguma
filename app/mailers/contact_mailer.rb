# app/mailers/contact_mailer.rb
class ContactMailer < ApplicationMailer
  default from: 'contact@ariaguma.jp'  # 送信元アドレス

  def reply_to_user(contact, subject, body)
    @contact = contact
    @body = body
    mail(
      to: @contact.email,
      subject: subject
    )
  end
end
