require 'securerandom'

class User < ActiveRecord::Base
  extend FriendlyId

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  friendly_id :name, use: [:slugged, :finders]

  has_many :mods, dependent: :nullify, foreign_key: :author_id
  has_many :owned_mods, class_name: 'Mod', foreign_key: :author_id, dependent: :nullify # We'll change it to User#owner_id eventually
  has_many :bookmarks
  has_many :bookmarked_mods, through: :bookmarks, source: :mod
  has_one :author

  ### Scopes
  #################

  scope :for_validation, -> do
    where(is_dev: false, is_admin: false)
      .joins(:owned_mods).where.not(mods: { id: nil })
      .uniq
  end

  def self.find_for_database_authentication(conditions)
    conditions[:login].downcase!
    conditions[:login].strip!
    where('lower(email) = :login or lower(name) = :login', conditions).first
  end

  ### Callbacks
  #################

  before_validation do
    self.name = name.strip.squeeze(' ')
  end

  ### Validations
  #################

  validates :name, presence: true,
                   format: { with: /\A[[:alnum:]\-_\. ]+\Z/i },
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 50 }

  ### Initializers
  #################

  def self.autogenerate(attributes)
    attributes = attributes.reverse_merge(
      email: SecureRandom.hex(25) + '@' + SecureRandom.hex(25) + '.com',
      password: SecureRandom.hex(25),
      autogenerated: true
    )
    User.new attributes
  end

  ### Methods
  #################

  def validate!
    owned_mods.each{ |om| om.update!(visible: true) } unless is_dev? or is_admin?
    self.is_dev = true
    save!
  end

  def give_ownership_of_authored!
    if author
      author.mods.each.each{ |am| am.update!(owner: self) unless am.owner.present? }
    end
  end

  def has_bookmarked_mod?(mod)
    @bookmarked_mods_ids ||= Bookmark.where(user: self).pluck(:mod_id)
    @bookmarked_mods_ids.include? mod.id
  end

  ### Attributes
  #################

  attr_accessor :login

  def non_owned_authored_mods
    return [] unless author
    author.mods - owned_mods
  end

  def needs_validation?
    !is_dev? and !is_admin? and owned_mods.any?
  end

  # For validation
  def password_required?
    # We need to validate the password when the user
    # registers with previously autogenerated user
    super || (!autogenerated && autogenerated_was)
  end

  def is_registered?
    !new_record?
  end

  def is_guest?
    new_record?
  end
end
