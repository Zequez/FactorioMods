require 'securerandom'

class ForumValidation < ActiveRecord::Base
  belongs_to :user
  belongs_to :author

  # Generate #vid
  before_save do
    self.vid = SecureRandom.hex(25) # 50
  end

  validates :user, presence: true
  validates :author, presence: true

  def associate_user_and_author!
    author.user = user
    author.save!
    update_column :validated, true
  end
end
