# app/models/regist.rb
require 'digest'

class Regist < ApplicationRecord
  before_validation :set_email_hash

  # 仮想属性（DBに保存しないがフォームから受け取る）
  attr_accessor :email_confirmation
  attr_accessor :reply_subject, :reply_body

  encrypts :email

  has_many :regists_replies

  validates :name, presence: true
  validates :email, presence: true
  validates :email_confirmation, presence: true, on: :create
  validate :email_matches_confirmation, on: :create
  validates :email_hash, uniqueness: { message: "はすでに登録されています。" }
  validate :copy_email_hash_error_to_email

  # 返信用（仮想属性）
  validates :reply_subject, presence: { message: "件名を入力してください" }, if: :replying?
  validates :reply_body, presence: { message: "本文を入力してください" }, if: :replying?

  after_create :send_download_email

  private

  def replying?
    reply_subject.present? || reply_body.present?
  end

  def set_email_hash
    if email.present? && will_save_change_to_email?
      self.email_hash = Digest::SHA256.hexdigest(email.to_s.downcase.strip)
    end
  end

  def email_matches_confirmation
    if email.present? && email_confirmation.present? && email != email_confirmation
      errors.add(:email_confirmation, "が一致していません")
      errors.add(:email, "と確認用メールアドレスが一致していません") # ←追加
    end
  end

  def copy_email_hash_error_to_email
    if errors[:email_hash].any? && errors[:email].blank?
      errors.add(:email, errors[:email_hash].first)
    end
  end

  ## 現在、使われていない様子
  def send_download_email
    RegistMailer.download_email(self).deliver_later

    RegistsReply.create!(
      name: self.name,
      subject: '『幻魔との死闘』無料電子書籍の予約完了通知（自動）',
      email_hash: self.email_hash,
      message: "ダウンロードURLメールの予約を受け付け、予約者のデータをDBに保存しました（#{Time.current.strftime('%Y/%m/%d %H:%M:%S')}）",
      regist_id: self.id
    )

    # 1通目のメールの送信日時をregist.email_sent_01に保存
    self.update_column(:email_sent_01, Time.current)
  end

end
