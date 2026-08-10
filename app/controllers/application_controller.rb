class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception # CSRF（クロスサイトリクエストフォージェリ）対策
  include SessionsHelper
  helper_method :current_user
  helper_method :current_user_info
  helper_method :logged_in?

  add_flash_types :admin_notice, :admin_alert

  def current_user
    #return unless session[:email_hash]
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_user_info
    return unless current_user
    {
      id: current_user.id,
      name: current_user.name,
      email_hash: current_user.email_hash
    }
  end

  def authenticate_user!
    unless current_user
      session[:return_to] = request.fullpath
      redirect_to login_path #, alert: "ログインしてください。"
      #redirect_to management_screen_login_path, alert: "ログインしてください。"
    end
  end

  private

  def logged_in?
    Rails.logger.info "LOGIN_CHECK"
    Rails.logger.info "SESSION=#{session.to_hash.inspect}"
    Rails.logger.info "USER_ID=#{session[:user_id].inspect}"

    session[:user_id].present?
  end

  def require_login
    unless logged_in?
      flash[:admin_notice] = "ログインをしてください"
      Rails.logger.debug "FLASH BEFORE REDIRECT: #{flash.inspect}"
      redirect_to login_path
      #redirect_to management_screen_login_path
    end
  end

end

# Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
#  allow_browser versions: :modern

#  def after_sign_in_path_for(resource)
#    management_screen_path
#  end


#  def after_sign_out_path_for(resource_or_scope)
#    '/login/pages'
#  end

#  def after_sign_in_path_for(resource)
#    '/management_screen'
#  end

