class FirebaseSessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    Rails.logger.info "===== firebase_login START ====="

    id_token = params[:id_token]

    if id_token.blank?
      render json: { success: false, error: "id_token is blank" }, status: :unauthorized
      return
    end

    decoded_token = FirebaseIdToken::Signature.verify(id_token)

    if decoded_token.blank?
      render json: { success: false, error: "invalid token" }, status: :unauthorized
      return
    end

    firebase_uid = decoded_token["user_id"] || decoded_token["sub"]
    email = decoded_token["email"]
    name = decoded_token["name"].presence || email.split("@").first
    email_hash = Digest::SHA256.hexdigest(email)

    user = User.unscoped.find_by(firebase_uid: firebase_uid)
    user ||= User.unscoped.find_by(email: email)
    user ||= User.unscoped.find_by(email_hash: email_hash) if User.column_names.include?("email_hash")
    user ||= User.new

    user.firebase_uid = firebase_uid if User.column_names.include?("firebase_uid")
    user.email = email
    user.name = name if user.respond_to?(:name) && user.name.blank?

    if User.column_names.include?("email_hash") && user.email_hash.blank?
      user.email_hash = email_hash
    end

    if user.respond_to?(:password=) && user.password_digest.blank?
      user.password = SecureRandom.hex(16)
    end

    user.save!

    session[:user_id] = user.id

    render json: {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    }

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "===== firebase_login ERROR ====="
    Rails.logger.error e.class
    Rails.logger.error e.message
    Rails.logger.error e.record.errors.full_messages
    Rails.logger.error e.record.errors.details
    render json: { success: false, error: e.record.errors.full_messages }, status: :unauthorized

  rescue => e
    Rails.logger.error "===== firebase_login ERROR ====="
    Rails.logger.error e.class
    Rails.logger.error e.message
    render json: { success: false, error: e.message }, status: :unauthorized
  end

  def destroy
    Rails.logger.info "========== LOGOUT =========="
    reset_session
    redirect_to root_path
  end
end