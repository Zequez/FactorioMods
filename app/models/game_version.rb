class GameVersion < ActiveRecord::Base
  ### Scoping / Selectors
  #######################

  scope :select_older_versions, ->(game_version) { where('number < ?', game_version.number) }
  scope :select_newer_versions, ->(game_version) { where('number > ?', game_version.number) }
  scope :sort_by_older_to_newer, -> { order('number asc') }
  scope :sort_by_newer_to_older, -> { order('number desc') }

  def get_previous_version
    GameVersion.select_older_versions(self).sort_by_newer_to_older.first
  end

  def get_next_version
    GameVersion.select_newer_versions(self).sort_by_older_to_newer.first
  end

  ### Attributes
  #######################

  def level
    @level ||= (number || '').split('.').size
  end

  def sections(picked_level = level)
    @sections ||= (number || '').split('.').slice(0, picked_level)
  end

  def number=(_); @level = @sections = nil; super; end

  def is_first_in_level?(level_to_check)
    previous_version = get_previous_version
    return true if previous_version.nil?

    similarity_level = similarity_level(previous_version)

    # p 'Previous:    ' + previous_version.sections.inspect
    # p 'Version:     ' + sections.inspect
    # p 'Similarity:  ' + similarity_level.inspect
    # p 'Compare:     ' + compare_section(self.sections[similarity_level], previous_version.sections[similarity_level]).inspect

    if similarity_level >= level_to_check
      compare_section(self.sections[similarity_level], previous_version.sections[similarity_level]) < 0
    else
      true
    end
  end

  def is_last_in_level?(level_to_check)
    next_version = get_next_version
    return true if next_version.nil?

    similarity_level = similarity_level(next_version)

    if similarity_level >= level_to_check
      compare_section(self.sections[similarity_level], next_version.sections[similarity_level]) > 0
    else
      true
    end
  end

  def similarity_level(game_version)
    i = 0
    while (sections[i] == game_version.sections[i]) and (i < sections.size) do
      i += 1
    end
    i
  end

  def range_string(game_version)
    similarity = similarity_level(game_version)
    if is_first_in_level?(similarity) and game_version.is_last_in_level?(similarity)
      (sections[0, similarity] + ['x']).join('.')
    else
      "#{number}-#{game_version.number}"
    end
  end

  # A helper, not actually part of the model
  def compare_section(section1, section2)
    return 0 if section1.nil? and section2.nil?
    return -1 if section1.nil?
    return 1 if section2.nil?

    numeric1 = section1.match(/[0-9]+/).to_s.to_i
    numeric2 = section2.match(/[0-9]+/).to_s.to_i
    alpha1 = section1.match(/[a-z]+/).to_s
    alpha2 = section2.match(/[a-z]+/).to_s

    if numeric1 == numeric2
      alpha1 <=> alpha2
    else
      numeric1 - numeric2
    end
  end

  def to_label
    number
  end
end
