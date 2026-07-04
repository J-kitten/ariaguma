# app/controllers/home_controller.rb
class HomeController < ApplicationController

  def index
    @regist = Regist.new
    @current_user = current_user
  end

  def create # CODE CHECK OK 2026/6/26
    @regist = Regist.new(regist_params)
    @regist.token = SecureRandom.hex(16)
    @regist.second_token = SecureRandom.hex(16)

    # TEMPLATE FILES
    # app/views/regist_mailer/notify_admin.text.erb || notify_admin.text.erb
    # app/views/regist_mailer/download_email.text.erb || download_email.text.erb
    if @regist.save
      begin
        RegistMailer.download_email(@regist).deliver_now    # 送信者へ自動返信
        RegistMailer.notify_admin(@regist).deliver_now      # 管理者宛の通知
      rescue => e
        Rails.logger.error("メール送信失敗: #{e.message}")
        # エラー通知なども必要ならここに追加
      end

      flash[:admin_notice] = "予約登録が完了しました。"
      redirect_to root_path
    else
      flash.now[:admin_alert] = "入力内容に不備があります。"
      render :index
    end

  end

  def contact
    @contact = Contact.new
  end

  def activity
  end

  def about
  end

  private

  def regist_params
    params.require(:regist).permit(:second_token, :name, :email, :email_confirmation)
  end

end


