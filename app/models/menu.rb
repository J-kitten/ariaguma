# app/models/menu.rb
class Menu < ApplicationRecord
  has_many :menu_ingredients,
           dependent: :destroy

  has_many :menu_steps,
           dependent: :destroy

  has_many :menu_nutritions,
           dependent: :destroy

  has_many :menu_nutrient_values,
           dependent: :destroy

  has_many :nutrients,
           through: :menu_nutrient_values

  accepts_nested_attributes_for :menu_ingredients,
                                allow_destroy: true,
                                reject_if: :all_blank

  accepts_nested_attributes_for :menu_steps,
                                allow_destroy: true,
                                reject_if: :all_blank
end