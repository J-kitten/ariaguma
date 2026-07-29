# app/models/menu_nutrient_value.rb
class MenuNutrientValue < ApplicationRecord
  belongs_to :menu
  belongs_to :nutrient
end