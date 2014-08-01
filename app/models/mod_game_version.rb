class ModGameVersion < ActiveRecord::Base
  belongs_to :game_version
  belongs_to :mod_version
  belongs_to :mod

  before_save do
    if not mod_id and mod_version
      self.mod_id = mod_version.mod_id
    end
  end

  after_create :expire_game_versions_string
  after_destroy :expire_game_versions_string

  def expire_game_versions_string
    if mod and not mod.new_record?
      mod.update_column :game_versions_string, nil
    end

    if mod_version and not mod_version.new_record?
      mod_version.update_column :game_versions_string, nil
    end
  end
end
