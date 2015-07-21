class AuthorsMod < ActiveRecord::Base
  belongs_to :mod
  belongs_to :author, class_name: 'User'
end
