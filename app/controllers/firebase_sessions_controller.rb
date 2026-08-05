class FirebaseSessionsController < ApplicationController
  def create
    Rails.logger.info "===== firebase_login START ====="

    id_token = params[:id_token]

    if id_token.blank?
      render json: {
        success: false,
        error: "id_token is blank"
      }, status: :unauthorized
      return
    end

    decoded_token = verify_firebase_token(id_token)

    if decoded_token.blank?
      render json: {
        success: false,
        error: "invalid token"
      }, status: :unauthorized
      return
    end

    firebase_uid =
      decoded_token["user_id"] ||
      decoded_token["sub"]

    email = decoded_token["email"]

    if firebase_uid.blank? || email.blank?
      render json: {
        success: false,
        error: "Firebase token has no uid or email"
      }, status: :unauthorized
      return
    end

    name =
      decoded_token["name"].presence ||
      email.split("@").first

    email_hash = Digest::SHA256.hexdigest(email)

    user =
      User.unscoped.find_by(
        firebase_uid: firebase_uid
      )

    user ||=
      User.unscoped.find_by(
        email: email
      )

    if user.blank? &&
       User.column_names.include?("email_hash")
      user =
        User.unscoped.find_by(
          email_hash: email_hash
        )
    end

    user ||= User.new

    if User.column_names.include?("firebase_uid")
      user.firebase_uid = firebase_uid
    end

    user.email = email

    if user.respond_to?(:name) &&
       user.name.blank?
      user.name = name
    end

    if User.column_names.include?("email_hash") &&
       user.email_hash.blank?
      user.email_hash = email_hash
    end

    if user.respond_to?(:password=) &&
       user.password_digest.blank?
      user.password = SecureRandom.hex(16)
    end

    user.save!

    session[:user_id] = user.id

    Rails.logger.info(
      "===== firebase_login SUCCESS user_id=#{user.id} ====="
    )

    render json: {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    }

  rescue FirebaseIdToken::Exceptions::NoCertificatesError => e
    Rails.logger.error(
      "===== FIREBASE CERTIFICATE ERROR ====="
    )
    Rails.logger.error "#{e.class}: #{e.message}"

    render json: {
      success: false,
      error: "Firebase証明書を取得できませんでした"
    }, status: :service_unavailable

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(
      "===== firebase_login RECORD ERROR ====="
    )
    Rails.logger.error e.class
    Rails.logger.error e.message
    Rails.logger.error e.record.errors.full_messages
    Rails.logger.error e.record.errors.details

    render json: {
      success: false,
      error: e.record.errors.full_messages
    }, status: :unprocessable_entity

  rescue StandardError => e
    Rails.logger.error(
      "===== firebase_login ERROR ====="
    )
    Rails.logger.error e.class
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.first(10).join("\n")

    render json: {
      success: false,
      error: e.message
    }, status: :unauthorized
  end

  def destroy
    Rails.logger.info "========== LOGOUT =========="
    reset_session
    redirect_to root_path
  end

  private

  def verify_firebase_token(id_token)
    attempts = 0

    begin
      attempts += 1

      FirebaseIdToken::Signature.verify(id_token)

    rescue FirebaseIdToken::Exceptions::NoCertificatesError => e
      Rails.logger.warn(
        "Firebase certificates are missing: #{e.message}"
      )

      raise if attempts >= 2

      Rails.logger.info(
        "Requesting Firebase certificates..."
      )

      FirebaseIdToken::Certificates.request!

      retry
    end
  end
end