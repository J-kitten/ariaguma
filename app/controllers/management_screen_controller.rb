# app/controllers/management_screen_controller.rb
class ManagementScreenController < ApplicationController
  layout 'management' # app/views/layouts/management.html.erb
  before_action :require_login, only: [:regists, :contacts]
  #before_action :authenticate_user!  # Devise のコードなので不要

  def not_found
    redirect_to management_screen_path
  end

  def index
    # 認証チェックなどがあればここに書く
    render :index  # views/management/index.html.erb を表示
  end

  def logout
  end

  private

  def require_login
Rails.logger.info ENV["SMTP_USER_NAME"].inspect
Rails.logger.info ENV["SMTP_PASSWORD"].present?
    unless logged_in?
      flash[:notice] = "ログインをしてください。★"
      Rails.logger.debug "FLASH DEBUG: #{flash.inspect}"  # ← これで確認
      redirect_to login_path
      #redirect_to '/login/' unless session[:email_hash]
    end
  end

  def regists
    # ログインしていない場合はここに来る前にリダイレクトされます
    flash[:notice] = "ログインをしてください。"
  end

  def contacts
    # ログインしていない場合はここに来る前にリダイレクトされます
    flash[:notice] = "ログインをしてください。"
  end

end
