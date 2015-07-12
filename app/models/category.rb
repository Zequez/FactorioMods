class Category < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_and_belongs_to_many :mods

  validates :name, uniqueness: true

  scope :order_by_mods_count, -> { order('mods_count desc') }
  scope :order_by_name, -> { order('name asc') }
end
