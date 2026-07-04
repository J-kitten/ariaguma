# app/controllers/management_screen/sessions_controller.rb
module ManagementScreen
  class SessionsController < ApplicationController

    layout 'management'

    def new
    end

    def index
    end

    def create
      email = params[:email]
      password = params[:password]

      if email.blank? || password.blank?
        flash.now[:alert] = "メールアドレスとパスワードは必須です controllers/management_screen/session_controller.rb"
        render :new, status: :unprocessable_entity
        return
      end

      if email.blank?
        flash.now[:alert] = "メールアドレス入力は必須です"
        render :new, status: :unprocessable_entity
        return
      end

      if password.blank?
        flash.now[:alert] = "パスワード入力は必須です"
        render :new, status: :unprocessable_entity
        return
      end

      user = User.find_by_email_hash(email)  # DBで比較

      if user && user.authenticate(password)
        # session[:user_id]がないと app/controllers/management_screen/base_controller.rb 
        # 内の、require_login が動かない
        session[:user_id] = user.id
        session[:email_hash] = user.email_hash
        redirect_to management_screen_path, notice: "ログインに成功しました controllers/management_screen/session_controller.rb"
      else
        flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session  # これで session[:email_hash] も含め、すべて消える
      redirect_to management_screen_login_path, notice: "ログアウトしました"
    end

    def destroy_view
      # logout 完了ページ（destroy.html.erb）を表示
    end

  end
end
