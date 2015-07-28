class ModsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value,
           :entry_name, :total_count, :offset_value, :last_page?,
           :game_version, :category, :sorted_by

  def all_count
   @all_count ||= Mod.visible.count
  end

  def uncategorized_count
    @visible_count ||= object.uncategorized.count
  end
end
