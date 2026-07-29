class Api::ProfileController < ApplicationController
  protect_from_forgery with: :exception

  def update
    user = current_user

    unless user
      render json: { error: "ログインしてください" }, status: :unauthorized
      return
    end

    user.update!(name: params[:name])

    render json: {
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    }
  end
end
