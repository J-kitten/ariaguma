#app/controllers/google_auth_controller.rb
class GoogleAuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session

  def login
    token = params[:credential]

    payload = FirebaseIdToken::Signature.verify(token)

    user = User.find_or_create_by(email: payload["email"]) do |u|
      u.name = payload["name"]
      u.password = SecureRandom.hex(32)
    end

    session[:user_id] = user.id

    render json: {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    }
  end

  def logout
    reset_session

    render json: {
      success: true
    }
  end

end
