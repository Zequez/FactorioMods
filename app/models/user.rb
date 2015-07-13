class User < ActiveRecord::Base
  extend FriendlyId

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  friendly_id :name, use: [:slugged, :finders]

  def is_registered?
    !new_record?
  end

  def is_guest?
    new_record?
  end

  validates :name, presence: true, format: { with: /\A[A-Z0-9\-_]+\Z/i }, uniqueness: { case_sensitive: false }
end
