class GameVersion < ActiveRecord::Base
  belongs_to :game
  # belongs_to :group, class_name: 'GameVersionGroup'
  # belongs_to :group, class_name: 'GameVersion'
  # has_many :sub_versions, class_name: 'GameVersion', foreign_key: :group_id

  ### Scoping / Selectors
  #######################

  # scope :select_older_versions, ->(game_version) { where('sort_order < ?', game_version.sort_order) }
  # scope :select_newer_versions, ->(game_version) { where('sort_order > ?', game_version.sort_order) }
  # scope :groups, -> { where(is_group: true) }
  scope :sort_by_older_to_newer, -> { order('sort_order asc') }
  scope :sort_by_newer_to_older, -> { order('sort_order desc') }

  # def get_previous_version
  #   GameVersion.select_older_versions(self).sort_by_newer_to_older.first
  # end

  # def get_next_version
  #   GameVersion.select_newer_versions(self).sort_by_older_to_newer.first
  # end

  ### Validations
  #######################

  # validate :validate_group_nesting
  # validate :validate_non_group_grouping
  # validate :validate_sort_order_lower_than_group

  # def validate_group_nesting
  #   if group_id and is_group?
  #     errors[:group] << "Can't nest groups"
  #   end
  # end

  # def validate_non_group_grouping
  #   if group_id and not group.is_group?
  #     errors[:group] << "That version is not a group"
  #   end
  # end

  # def validate_sort_order_lower_than_group
  #   if group_id and group.sort_order < sort_order
  #     errors[:group] << "Group cannot be a lower order"
  #   end
  # end

  ### Callbacks
  #######################

  before_save do
    if sort_order.nil?
      older = GameVersion.sort_by_newer_to_older.first
      if older
        self.sort_order = older.sort_order+1
      else
        self.sort_order = 0
      end
    end
  end

  ### Attributes
  #######################

  # def number=(_); @level = @sections = nil; super; end
  def <=>(version)
    sort_order <=> version.sort_order
  end
  include Comparable

  def to_label
    number
  end
end
