class Author < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  auto_strip_attributes :name, :forum_name, :github_name, squish: true, nullify: false

  ### Relationships
  #################

  belongs_to :user
  has_many :authors_mods
  has_many :mods, through: :authors_mods

  ### Scopes and finders
  #################

  def self.find_by_slugged_name(name)
    find_by_slug normalize_friendly_id(name)
  end

  ### Callbacks
  #################

  # Add the slug validation error to the name
  after_validation do
    errors[:name].concat errors[:slug]
  end

  ### Validations
  #################

  validates :slug, uniqueness: true
  validates :forum_name, uniqueness: true
  validates :name, presence: true, format: { with: /[a-z]/ }

  private

  # Return always false so the regular slug name it's selected
  # and we can just validate uniqueness and add a validation error
  def self.exists_by_friendly_id?(slug)
    false
  end

  # This is declared by friendly_id, but we need to set it here explicitly
  def self.normalize_friendly_id(value)
    value.to_s.parameterize
  end
end
