class Category < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :mods, through: :categories_mods
  has_many :categories_mods, dependent: :destroy

  validates :name, uniqueness: true

  scope :order_by_mods_count, -> { order('mods_count desc') }
  scope :order_by_name, -> { order('name asc') }
end
