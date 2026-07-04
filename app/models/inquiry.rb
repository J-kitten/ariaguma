# app/models/inquiry.rb
require 'digest'
class Inquiry < ApplicationRecord

  # 仮想属性（DBに保存しないがフォームから受け取る）
  attr_accessor :email_confirmation

  # email を暗号化する
  encrypts :email

  # バリデーション
  validates :name, :subject, :email, :message, :email_confirmation, presence: true

  validate :email_matches_confirmation

  #scope :by_email, ->(email) { where(email: email) }

  private

  def email_matches_confirmation
    if email != email_confirmation
      errors.add(:email_confirmation, "が一致しません")
    end
  end

end
