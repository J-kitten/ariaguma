# app/models/nutrient.rb
class Nutrient < ApplicationRecord
  has_many :menu_nutrient_values,
           dependent: :restrict_with_error

  has_many :menus,
           through: :menu_nutrient_values
end