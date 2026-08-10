# app/controllers/logout_controller.rb
class LogoutController < ApplicationController
  def destroy
    reset_session
    render json: { success: true }
  end
end
