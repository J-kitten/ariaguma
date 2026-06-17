# app/controllers/management_screen/base_controller.rb
module ManagementScreen
  class BaseController < ApplicationController
    layout 'management'
    before_action :require_login  # 2025/11/21
   #before_action :require_management_login
  end

  private

  def require_login
    unless session[:user_id] && User.exists?(id: session[:user_id])
      flash[:notice] = "ログインをしてください"
      redirect_to login_url
      #redirect_to management_screen_login_path
    end
  end
end

#module ManagementScreen
#  class BaseController < ApplicationController
#    layout 'management'
#    before_action :require_management_login

#    private

#    def require_management_login
#      unless session[:user_id] && User.exists?(id: session[:user_id])
#        flash[:notice] = "ログインをしてください"
#        redirect_to management_screen_login_path
#      end
#    end

#  end
#end
