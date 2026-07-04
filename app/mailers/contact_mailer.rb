# app/mailers/contact_mailer.rb
class ContactMailer < ApplicationMailer
  default from: 'ARIAGUMA GROUP<contact@ariaguma.jp>'

  # 管理者通知
  def notify_admin(contact)
    @contact = contact

    mail(
      to: 'contact@ariaguma.jp',
      subject: 'ARIAGUMA GROUP お問い合わせが届きました',
      reply_to: @contact.email
    )
  end

  # 自動返信
  def auto_reply(contact)
    @contact = contact

    mail(
      to: @contact.email,
      subject: 'ARIAGUMA GROUP お問い合わせありがとうございます'
    )
  end

  def reply_to_user(contact, subject, body)
    @contact = contact
    @body = body
    mail(
      to: @contact.email,
      subject: subject
    )
  end


end
