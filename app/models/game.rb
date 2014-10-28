class Game < ActiveRecord::Base
  class CannotCreateMoreThanOneGameError < StandardError; end;

  has_many :versions, class_name: 'GameVersion'

  accepts_nested_attributes_for :versions, allow_destroy: true

  before_create do
    if Game.all.count != 0
      raise CannotCreateMoreThanOneGameError
    end
  end
end