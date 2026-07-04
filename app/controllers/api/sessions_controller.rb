#app/controllers/api/session_controller.rb
class Api::SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def me
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last

    render json: {
      auth_header: auth_header,
      token: token
    }
  end

end
