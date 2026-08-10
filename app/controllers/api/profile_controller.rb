# app/controllers/api/profile_controller.rb
class Api::ProfileController < ApplicationController
  protect_from_forgery with: :exception

  def update
    user = current_user

    unless user
      render json: {
        success: false,
        error_code: "UNAUTHORIZED",
        message: "ログインしてください。",
        details: {}
      }, status: :unauthorized
      return
    end

    user.update!(name: params[:name])

    Regist.where(
      email_hash: user.email_hash
    ).update_all(
      name: user.name
    )

    render json: {
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    }

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(
      "[Profile Update Validation Error] " \
      "#{e.class}: #{e.message}"
    )

    render json: {
      success: false,
      error_code: "VALIDATION_ERROR",
      message: "入力内容をご確認ください。",
      details: {
        errors: e.record.errors.full_messages
      }
    }, status: :unprocessable_entity

  rescue StandardError => e
    Rails.logger.error(
      "[Profile Update Error] " \
      "#{e.class}: #{e.message}"
    )

    render json: {
      success: false,
      error_code: "INTERNAL_ERROR",
      message: "プロフィール更新中にエラーが発生しました。",
      details: {}
    }, status: :internal_server_error
  end
end