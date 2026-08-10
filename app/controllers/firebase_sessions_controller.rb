# app/controllers/firebase_sessions_controller.rb
class FirebaseSessionsController < ApplicationController
  protect_from_forgery with: :exception
  def create
    Rails.logger.info "===== firebase_login START ====="

    id_token = params[:id_token]

    if id_token.blank?
      render json: {
        success: false,
        error_code: "UNAUTHORIZED",
        message: "認証情報がありません。",
        details: {}
      }, status: :unauthorized
      return
    end

    decoded_token = verify_firebase_token(id_token)

    if decoded_token.blank?
      render json: {
        success: false,
        error_code: "INVALID_TOKEN",
        message: "認証情報が無効です。",
        details: {}
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
        error_code: "INVALID_TOKEN",
        message: "認証情報が不完全です。",
        details: {}
      }, status: :unauthorized
      return
    end

    # メールアドレスを正規化
    email = email.to_s.downcase.strip

    name = decoded_token["name"].presence ||
           email.split("@").first

    email_hash = Digest::SHA256.hexdigest(email)

    user = User.unscoped.find_by(
             firebase_uid: firebase_uid
           )

    user ||= User.unscoped.find_by(
               email: email
             )

    if user.blank? &&
       User.column_names.include?("email_hash")
      user = User.unscoped.find_by(
              email_hash: email_hash
            )
    end

    user ||= User.new

    if User.column_names.include?("firebase_uid")
      user.firebase_uid = firebase_uid
    end

    user.email = email

    if user.respond_to?(:name) && user.name.blank?
      user.name = name
    end

    if User.column_names.include?("email_hash")
      user.email_hash = email_hash
    end

    if user.respond_to?(:password=) &&
       user.respond_to?(:password_digest) &&
       user.password_digest.blank?
      user.password = SecureRandom.hex(16)
    end

    user.save!

    # ----------------------------------------
    # Rails側のログインセッションを作成
    # ----------------------------------------
    session[:user_id] = user.id
    session[:email_hash] = email_hash

    # ----------------------------------------
    # ダウンロードURLから来た場合は元のURLへ戻す
    # 通常ログインの場合はマイページへ遷移
    # ----------------------------------------
    redirect_url = session.delete(:return_to_after_login).presence || mypage_path

    Rails.logger.info(
      "===== firebase_login SUCCESS " \
      "user_id=#{user.id} " \
      "redirect_url=#{redirect_url} ====="
    )

    render json: {
      success: true,
      redirect_url: redirect_url
    }

  rescue FirebaseIdToken::Exceptions::NoCertificatesError => e
    Rails.logger.error(
      "===== FIREBASE CERTIFICATE ERROR ====="
    )
    Rails.logger.error "#{e.class}: #{e.message}"

    render json: {
      success: false,
      error_code: "FIREBASE_CERTIFICATE_ERROR",
      message: "認証サービスとの通信に失敗しました。",
      details: {}
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
      error_code: "VALIDATION_ERROR",
      message: "ユーザー情報を保存できませんでした。",
      details: {
        errors: e.record.errors.full_messages
      }
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
      error_code: "INTERNAL_ERROR",
      message: "ログイン処理中にエラーが発生しました。",
      details: {}
    }, status: :internal_server_error
  end

  def destroy
    Rails.logger.info "========== LOGOUT =========="

    reset_session

    render json: {
      success: true
    }
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