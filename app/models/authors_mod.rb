class AuthorsMod < ActiveRecord::Base
  belongs_to :mod
  belongs_to :author
end
