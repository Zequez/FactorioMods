module HasGameVersions
  attr_accessor :game_versions_string

  has_and_belongs_to_many :game_versions
end