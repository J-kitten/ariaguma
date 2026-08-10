class Reply < ApplicationRecord
  validates :subject, :email_hash, :message, presence: true
  validates :subject, length: { maximum: 50 }
  validates :email_hash, length: { maximum: 255 }
  validates :message, length: { maximum: 5000 }

  validate :contact_or_regist_present

  private

  def contact_or_regist_present
    return if contact_id.present? || regist_id.present?

    errors.add(:base, "お問い合わせまたは予約者との関連付けが必要です")
  end
end
