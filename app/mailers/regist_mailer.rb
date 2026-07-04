# app/mailers/regist_mailer.rb

class RegistMailer < ApplicationMailer
  default from: 'ARIAGUMA GROUP<contact@ariaguma.jp>'

  # 予約登録画面で送信者が登録すると、予約完了のメールを管理者宛に通知
  # app/views/regist_mailer/notify_admin.text.erb
  # app/views/regist_mailer/notify_admin.html.erb
  def notify_admin(regist) # CODE CHECK OK 2026/6/26
    @regist = regist
    mail(
      to: 'contact@ariaguma.jp',
      subject: 'ARIAGUMA GROUP 予約完了通知がきました',
      reply_to: @regist.email
    )
  end

  # 予約登録画面で送信者が登録すると、予約完了のメール通知を自動返信
  # app/views/regist_mailer/download_email.text.erb
  # app/views/regist_mailer/download_email.html.erb
  def download_email(regist)
    @regist = regist
    #@download_url = "https://ariaguma.jp/download/#{@regist.token}"
    mail(
      to: @regist.email,
      subject: "Present電子書籍『死闘の使命』の予約完了 ARIAGUMA"
    )
  end

  # 送信者へダウンロードURLの通知
  # app/views/regist_mailer/notify_to_sender.text.erb
  # app/views/regist_mailer/notify_to_sender.html.erb
  def notify_to_sender(regist) # CODE CHECK OK 2026/6/26
    @regist = regist
    @download_url = "https://ariaguma.jp/download/#{@regist.token}"
    mail(
      to: @regist.email,
      subject: "Present電子書籍『死闘の使命』の予約完了 ARIAGUMA"
    )
  end

  # 2冊目の書籍作成が完了し、subscribed=1 ならダウンロードURLをメール通知する
  # app/mailers/regist_mailer.rb
  def second_download_email(regist)
    @regist = regist
    @regist.update!( second_token: SecureRandom.hex(16) )
    @download_url = "https://ariaguma.jp/download/second_download/#{@regist.second_token}" # ダウンロードURLを変更する

    mail(
      to: @regist.email,
      subject: "Present 2冊目電子書籍DOWNLOAD URLのご通知です ARIAGUMA"
    )
  end

  def reply_to_user(regist, subject, body)
    @regist = regist
    @body = body
    mail(
      to: @regist.email,
      subject: subject
    )
  end

end

