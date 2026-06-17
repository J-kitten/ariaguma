class AuthController < ApplicationController
  before_action :authenticate!, only: [:me]
  #protect_from_forgery with: :null_session

  def login
    token = request.headers["Authorization"]&.split(" ")&.last

    puts "TOKEN: #{token}" # デバッグ

    payload = FirebaseIdToken::Signature.verify(token)

    puts "PAYLOAD: #{payload}" # デバッグ

    account = Account.find_or_create_by(email: payload["email"]) do |a|
      a.name = payload["name"]
    end

    render json: {
      success: true,
      account: account
    }
  rescue => e
    puts "ERROR: #{e.message}"
    render json: { success: false, error: e.message }, status: 401
  end

  def me
    render json: {
      logged_in: true,
      account: current_account
    }
  end

  def logout
    render json: { success: true }
  end

  def authenticate!
    render json: { error: "unauthorized" } unless current_account
  end

end
