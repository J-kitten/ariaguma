# app/model/contact.rb
require 'digest'

class Contact < ApplicationRecord
  before_validation :set_email_hash

  # 仮想属性（DBに保存しないがフォームから受け取る）
  attr_accessor :email_confirmation
  attr_accessor :reply_subject, :reply_body

  # email を暗号化する（Rails 7 の encrypts 機能）
  encrypts :email

  # バリデーション
  validates :name, :subject, :email, :message, presence: true
  validates :email_confirmation, presence: true
  validates :email, confirmation: true,
                    length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, :subject, length: { maximum: 50 }
  validates :message, length: { maximum: 5000 }

  # 返信用（仮想属性）
  validates :reply_subject, presence: { message: "件名を入力してください" }, if: :replying?
  validates :reply_body, presence: { message: "本文を入力してください" }, if: :replying?

  # スコープ
  scope :unread_status, -> { where(unread: false) }
  scope :read, -> { where(unread: true) }

  private

  # email 確認用（仮想属性）との一致確認
#  def email_matches_confirmation
#    if email != email_confirmation
#      errors.add(:email_confirmation, "が一致しません")
#    end
#  end

  def replying?
    reply_subject.present? || reply_body.present?
  end

  # email をハッシュ化して保存
  def set_email_hash
    self.email_hash = Digest::SHA256.hexdigest(email.to_s.downcase.strip) if email.present?
  end
end
