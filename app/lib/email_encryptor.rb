# app/lib/email_encryptor.rb
require 'openssl'

class EmailEncryptor
  KEY = ENV["DETERMINISTIC_KEY"] || raise("DETERMINISTIC_KEY is missing")
  SALT = ENV["KEY_DERIVATION_SALT"] || raise("KEY_DERIVATION_SALT is missing")

  def self.encrypt(email)
    cipher = OpenSSL::Cipher::AES256.new(:ECB) # ECBで決定論的にする（同じ入力→同じ出力）
    cipher.encrypt
    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(KEY, SALT, 2000, 32)

    # 暗号化してBase64で文字列化
    encrypted = cipher.update(email) + cipher.final
    Base64.strict_encode64(encrypted)
  end
end

