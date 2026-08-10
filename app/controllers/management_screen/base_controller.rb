# app/controllers/management_screen/base_controller.rb

module ManagementScreen
  class BaseController < ApplicationController
    layout "management"

    before_action :require_login

    def not_found
      redirect_to management_screen_login_path
    end

    private

    def require_login
      return if session[:user_id].present? &&
                User.exists?(id: session[:user_id])

      reset_session

      redirect_to management_screen_login_path,
                  alert: "管理画面でログインしてください"
    end
  end
end