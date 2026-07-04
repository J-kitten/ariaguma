class Account < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end
