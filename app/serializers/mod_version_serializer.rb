class ModVersionSerializer < ActiveModel::Serializer
  attributes :id, :number, :released_at, :game_versions, :dependencies
  attribute :number, key: :version

  has_many :files

  def game_versions
    object.game_versions_string.split('-') # Ideally we should load the #game_versions
  end

  def dependencies
    [] # TODO
  end
end
