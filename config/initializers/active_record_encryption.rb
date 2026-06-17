# config/initializers/active_record_encryption.rb

Rails.application.config.active_record.encryption.tap do |enc|
  enc.primary_key         = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY")
  enc.deterministic_key   = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY")
  enc.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT")
end


