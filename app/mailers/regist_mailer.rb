# app/mailers/regist_mailer.rb

class RegistMailer < ApplicationMailer
  default from: 'contact@ariaguma.jp'

  def notify_admin(regist) # 'contact@ariaguma.jp'へ予約希望者からメール送信通知を受信
    @regist = regist
    mail(
      to: 'contact@ariaguma.jp',
      subject: 'ARIAGUMAサイトから予約完了通知がきました',
      from: @regist.email
    )
  end

  def download_email(regist) # 予約希望の送信者へ予約完了のメール通知を送る
    @regist = regist
    # @download_url = "https://ariaguma.jp/download/#{@regist.token}"
    mail(
      to: @regist.email,
      subject: "無料電子書籍『幻魔との死闘』の予約完了 ARIA GUMA"
    )
  end

  def second_download_email(regist) # 2冊目の書籍作成が完了し、subscribed=1 ならダウンロードURLをメール通知する
    @regist = regist
    @download_url = "https://ariaguma.jp/download/#{@regist.token}" # ダウンロードURLを変更する

    mail(
      to: @regist.email,
      from: 'contact@ariaguma.jp',
      subject: "【2冊目】電子書籍ダウンロードURLのご案内 ARIA GUMA"
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

